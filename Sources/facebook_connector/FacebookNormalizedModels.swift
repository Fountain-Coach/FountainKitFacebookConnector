import Foundation

public struct Post: Codable, Equatable, Sendable {
    public let id: String
    public let createdAt: String
    public let text: String?
    public let permalink: String?
    public let images: [ImageAsset]

    public init(
        id: String,
        createdAt: String,
        text: String?,
        permalink: String?,
        images: [ImageAsset]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.text = text
        self.permalink = permalink
        self.images = images
    }
}

public struct ImageAsset: Codable, Equatable, Sendable {
    public let url: String
    public let source: String
    public let postId: String
    public let attachmentId: String?

    public init(url: String, source: String = "facebook", postId: String, attachmentId: String? = nil) {
        self.url = url
        self.source = source
        self.postId = postId
        self.attachmentId = attachmentId
    }
}
