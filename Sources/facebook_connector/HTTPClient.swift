import Foundation

public struct HTTPClientConfiguration: Sendable {
    public var timeoutSeconds: TimeInterval
    public var maxRetries: Int
    public var baseBackoffSeconds: TimeInterval

    public init(timeoutSeconds: TimeInterval = 30, maxRetries: Int = 3, baseBackoffSeconds: TimeInterval = 0.5) {
        self.timeoutSeconds = timeoutSeconds
        self.maxRetries = maxRetries
        self.baseBackoffSeconds = baseBackoffSeconds
    }
}

public final class HTTPClient: @unchecked Sendable {
    private let session: URLSession
    private let config: HTTPClientConfiguration

    public init(session: URLSession = .shared, config: HTTPClientConfiguration = .init()) {
        self.session = session
        self.config = config
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var attempt = 0
        while true {
            do {
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    throw FacebookConnectorError.invalidResponseShape("Expected HTTPURLResponse.")
                }
                if shouldRetry(statusCode: http.statusCode), attempt < config.maxRetries {
                    let delay = retryDelaySeconds(attempt: attempt, retryAfter: http.value(forHTTPHeaderField: "Retry-After"))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    attempt += 1
                    continue
                }
                return (data, http)
            } catch {
                if attempt < config.maxRetries, shouldRetry(error: error) {
                    let delay = retryDelaySeconds(attempt: attempt, retryAfter: nil)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    attempt += 1
                    continue
                }
                throw error
            }
        }
    }

    private func shouldRetry(statusCode: Int) -> Bool {
        if statusCode == 429 { return true }
        return statusCode >= 500 && statusCode <= 599
    }

    private func shouldRetry(error: Error) -> Bool {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain {
            switch ns.code {
            case NSURLErrorTimedOut,
                 NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorNotConnectedToInternet,
                 NSURLErrorDNSLookupFailed:
                return true
            default:
                return false
            }
        }
        return false
    }

    private func retryDelaySeconds(attempt: Int, retryAfter: String?) -> TimeInterval {
        if let retryAfter, let seconds = TimeInterval(retryAfter), seconds > 0 {
            return seconds
        }
        let backoff = config.baseBackoffSeconds * pow(2.0, Double(attempt))
        let jitter = TimeInterval.random(in: 0...(config.baseBackoffSeconds * 0.2))
        return min(20, backoff + jitter)
    }
}
