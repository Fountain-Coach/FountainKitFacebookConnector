import Foundation

public struct FacebookUserPostsPage: Sendable, Equatable {
    public let posts: [Post]
    public let after: String?

    public init(posts: [Post], after: String?) {
        self.posts = posts
        self.after = after
    }
}

public final class FacebookGraphClient: @unchecked Sendable {
    private let http: HTTPClient
    private let logger: FacebookConnectorLogger

    public init(http: HTTPClient = .init(), logger: FacebookConnectorLogger = FacebookNullLogger()) {
        self.http = http
        self.logger = logger
    }

    public func fetchMyPostsImages(
        accessToken: String,
        limit: Int = FacebookGraph.DEFAULT_LIMIT,
        after: String? = nil
    ) async throws -> FacebookUserPostsPage {
        let token = accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            throw FacebookConnectorError.authRequired("Missing Facebook access token.")
        }

        let effectiveLimit = max(1, min(FacebookGraph.MAX_LIMIT, limit))
        var components = URLComponents(url: FacebookGraph.BASE_URL, resolvingAgainstBaseURL: false)
        components?.path = "/\(FacebookGraph.API_VERSION)/me/posts"
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "fields", value: FacebookGraph.FIELDS_USER_POSTS_IMAGES),
            URLQueryItem(name: "limit", value: String(effectiveLimit))
        ]
        if let after = after?.trimmingCharacters(in: .whitespacesAndNewlines), !after.isEmpty {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw FacebookConnectorError.invalidConfiguration("Failed to build Graph URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, httpResponse) = try await http.send(request)
        if httpResponse.statusCode >= 400 {
            throw Self.mapGraphError(data: data, response: httpResponse)
        }

        let normalized = try FacebookNormalizer.normalizeUserPostsResponse(data)
        logger.info("Fetched \(normalized.posts.count) posts (limit=\(effectiveLimit)).")
        return FacebookUserPostsPage(posts: normalized.posts, after: normalized.after)
    }

    static func mapGraphError(data: Data, response: HTTPURLResponse) -> FacebookConnectorError {
        let status = response.statusCode
        let retryAfter = response.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)

        if status == 429 {
            return .rateLimited(retryAfterSeconds: retryAfter)
        }

        if let graph = try? JSONDecoder().decode(GraphErrorEnvelope.self, from: data),
           let err = graph.error {
            let message = (err.message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let code = err.code ?? 0

            if code == 190 || status == 401 {
                return .authRequired(message.isEmpty ? "Facebook token invalid or expired." : message)
            }
            if code == 10 {
                return .permissionMissing(message.isEmpty ? "Missing required Facebook permission(s)." : message)
            }
            if code == 4 || code == 17 {
                return .rateLimited(retryAfterSeconds: retryAfter)
            }

            return .http(status: status, message: message.isEmpty ? "Graph API error." : message)
        }

        let fallbackMessage = HTTPURLResponse.localizedString(forStatusCode: status)
        return .http(status: status, message: fallbackMessage)
    }
}
