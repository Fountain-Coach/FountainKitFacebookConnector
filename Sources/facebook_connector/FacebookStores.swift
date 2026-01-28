import Foundation

public protocol FacebookTokenStore: Sendable {
    func readToken(userId: String) async throws -> FacebookStoredToken?
    func writeToken(userId: String, token: FacebookStoredToken) async throws
    func deleteToken(userId: String) async throws
}

public struct FacebookStoredToken: Codable, Equatable, Sendable {
    public let accessToken: String
    public let expiresAt: String?

    public init(accessToken: String, expiresAt: String?) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
    }
}

public protocol FacebookArtifactStore: Sendable {
    func upsertPosts(userId: String, posts: [Post]) async throws
    func deleteUserData(userId: String) async throws
}

public actor InMemoryFacebookTokenStore: FacebookTokenStore {
    private var tokens: [String: FacebookStoredToken] = [:]

    public init() {}

    public func readToken(userId: String) async throws -> FacebookStoredToken? {
        tokens[userId]
    }

    public func writeToken(userId: String, token: FacebookStoredToken) async throws {
        tokens[userId] = token
    }

    public func deleteToken(userId: String) async throws {
        tokens.removeValue(forKey: userId)
    }
}

public actor InMemoryFacebookArtifactStore: FacebookArtifactStore {
    private var postsByUser: [String: [Post]] = [:]

    public init() {}

    public func upsertPosts(userId: String, posts: [Post]) async throws {
        postsByUser[userId] = posts
    }

    public func deleteUserData(userId: String) async throws {
        postsByUser.removeValue(forKey: userId)
    }
}
