import Foundation

public enum FacebookGraph {
    public static let API_VERSION = "v24.0"
    public static let BASE_URL = URL(string: "https://graph.facebook.com")!

    // Canonical contract fields string (do not fan out beyond this without explicit product approval).
    public static let FIELDS_USER_POSTS_IMAGES =
        "message,created_time,permalink_url,attachments{media_type,media,url,subattachments}"

    public static let DEFAULT_LIMIT = 25
    public static let MAX_LIMIT = 100
}
