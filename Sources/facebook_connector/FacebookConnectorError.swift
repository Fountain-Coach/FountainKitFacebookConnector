import Foundation

public enum FacebookConnectorError: Error, LocalizedError, Sendable, Equatable {
    case invalidConfiguration(String)
    case authRequired(String)
    case permissionMissing(String)
    case rateLimited(retryAfterSeconds: Int?)
    case http(status: Int, message: String)
    case invalidResponseShape(String)
    case decodingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let msg):
            return msg
        case .authRequired(let msg):
            return msg
        case .permissionMissing(let msg):
            return msg
        case .rateLimited(let retryAfterSeconds):
            if let retryAfterSeconds {
                return "Meta Graph API rate limited. Retry after \(retryAfterSeconds)s."
            }
            return "Meta Graph API rate limited. Retry later."
        case .http(let status, let message):
            return "Meta Graph API HTTP \(status): \(message)"
        case .invalidResponseShape(let msg):
            return msg
        case .decodingFailed(let msg):
            return msg
        }
    }
}
