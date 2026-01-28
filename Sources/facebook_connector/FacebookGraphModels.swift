import Foundation

struct GraphResponse: Decodable, Sendable {
    let data: [GraphPost]?
    let paging: GraphPaging?
}

struct GraphPost: Decodable, Sendable {
    let id: String?
    let message: String?
    let created_time: String?
    let permalink_url: String?
    let attachments: GraphAttachmentsContainer?
}

struct GraphPaging: Decodable, Sendable {
    let cursors: GraphCursors?
    let next: String?
}

struct GraphCursors: Decodable, Sendable {
    let before: String?
    let after: String?
}

struct GraphAttachmentsContainer: Decodable, Sendable {
    let data: [GraphAttachment]?
}

struct GraphAttachment: Decodable, Sendable {
    let media_type: String?
    let media: GraphMedia?
    let url: String?
    let subattachments: GraphAttachmentsContainer?
}

struct GraphMedia: Decodable, Sendable {
    let image: GraphImage?
}

struct GraphImage: Decodable, Sendable {
    let src: String?
}

struct GraphErrorEnvelope: Decodable, Sendable {
    struct GraphError: Decodable, Sendable {
        let message: String?
        let type: String?
        let code: Int?
        let error_subcode: Int?
        let fbtrace_id: String?
    }

    let error: GraphError?
}
