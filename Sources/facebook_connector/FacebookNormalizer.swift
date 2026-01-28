import Foundation

public enum FacebookNormalizer {
    public struct Result: Sendable, Equatable {
        public let posts: [Post]
        public let after: String?

        public init(posts: [Post], after: String?) {
            self.posts = posts
            self.after = after
        }
    }

    public static func normalizeUserPostsResponse(_ data: Data) throws -> Result {
        let decoder = JSONDecoder()
        let response: GraphResponse
        do {
            response = try decoder.decode(GraphResponse.self, from: data)
        } catch {
            throw FacebookConnectorError.decodingFailed("Failed to decode Graph JSON: \(error.localizedDescription)")
        }

        let posts = (response.data ?? []).compactMap { normalize(post: $0) }
        let after = response.paging?.cursors?.after?.trimmingCharacters(in: .whitespacesAndNewlines)
        return Result(posts: posts, after: after?.isEmpty == false ? after : nil)
    }

    private static func normalize(post: GraphPost) -> Post? {
        let id = (post.id ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { return nil }

        let createdAt = (post.created_time ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let text = normalizeOptionalString(post.message)
        let permalink = normalizeOptionalString(post.permalink_url)
        let images = extractImages(from: post.attachments, postId: id)
        return Post(id: id, createdAt: createdAt, text: text, permalink: permalink, images: images)
    }

    private static func normalizeOptionalString(_ value: String?) -> String? {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func extractImages(from container: GraphAttachmentsContainer?, postId: String) -> [ImageAsset] {
        var urls: [String] = []
        urls.reserveCapacity(4)
        walkAttachments(container, into: &urls)
        let deduped = stableDedup(urls)
        return deduped.map { ImageAsset(url: $0, source: "facebook", postId: postId, attachmentId: nil) }
    }

    private static func walkAttachments(_ container: GraphAttachmentsContainer?, into urls: inout [String]) {
        guard let attachments = container?.data, !attachments.isEmpty else { return }
        for attachment in attachments {
            if shouldIncludeImage(for: attachment), let src = normalizedURL(attachment.media?.image?.src) {
                urls.append(src)
            }
            walkAttachments(attachment.subattachments, into: &urls)
        }
    }

    private static func shouldIncludeImage(for attachment: GraphAttachment) -> Bool {
        let mediaType = (attachment.media_type ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if mediaType.contains("video") { return false }
        if let src = normalizedURL(attachment.media?.image?.src) {
            return !looksLikeVideoURL(src)
        }
        return false
    }

    private static func normalizedURL(_ value: String?) -> String? {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func looksLikeVideoURL(_ url: String) -> Bool {
        let lower = url.lowercased()
        return lower.contains(".mp4") || lower.contains(".mov") || lower.contains(".m4v")
    }

    private static func stableDedup(_ urls: [String]) -> [String] {
        var seen: Set<String> = []
        seen.reserveCapacity(urls.count)
        var out: [String] = []
        out.reserveCapacity(urls.count)
        for url in urls {
            if seen.insert(url).inserted {
                out.append(url)
            }
        }
        return out
    }
}
