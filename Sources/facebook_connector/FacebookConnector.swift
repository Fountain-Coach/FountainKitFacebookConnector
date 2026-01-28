import Foundation

public final class FacebookConnector: @unchecked Sendable {
    private let oauth: FacebookOAuthClient
    private let graph: FacebookGraphClient
    private let tokenStore: FacebookTokenStore
    private let artifactStore: FacebookArtifactStore

    public init(
        oauth: FacebookOAuthClient,
        graph: FacebookGraphClient = .init(),
        tokenStore: FacebookTokenStore,
        artifactStore: FacebookArtifactStore
    ) {
        self.oauth = oauth
        self.graph = graph
        self.tokenStore = tokenStore
        self.artifactStore = artifactStore
    }

    public func authorizationURL(state: String, scope: [String] = ["user_posts"]) throws -> URL {
        try oauth.authorizationURL(state: state, scope: scope)
    }

    public func handleOAuthCallback(userId: String, code: String) async throws -> FacebookStoredToken {
        let token = try await oauth.exchangeCodeForToken(code: code)
        let expiresAt = token.expiresIn.flatMap { seconds -> String in
            let date = Date().addingTimeInterval(TimeInterval(seconds))
            return ISO8601DateFormatter().string(from: date)
        }
        let stored = FacebookStoredToken(accessToken: token.accessToken, expiresAt: expiresAt)
        try await tokenStore.writeToken(userId: userId, token: stored)
        return stored
    }

    public func fetchAndStoreMyPostsImages(
        userId: String,
        limit: Int = FacebookGraph.DEFAULT_LIMIT,
        after: String? = nil
    ) async throws -> FacebookUserPostsPage {
        guard let token = try await tokenStore.readToken(userId: userId) else {
            throw FacebookConnectorError.authRequired("No stored Facebook token. Connect your account first.")
        }
        let page = try await graph.fetchMyPostsImages(
            accessToken: token.accessToken,
            limit: limit,
            after: after
        )
        try await artifactStore.upsertPosts(userId: userId, posts: page.posts)
        return page
    }

    public func disconnect(userId: String) async throws {
        try await tokenStore.deleteToken(userId: userId)
    }

    public func delete_user_data(userId: String) async throws {
        try await artifactStore.deleteUserData(userId: userId)
    }
}
