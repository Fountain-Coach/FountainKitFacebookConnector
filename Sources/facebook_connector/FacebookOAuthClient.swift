import Foundation

public struct FacebookOAuthConfig: Sendable {
    public let appId: String
    public let appSecret: String
    public let redirectURI: String

    public init(appId: String, appSecret: String, redirectURI: String) {
        self.appId = appId
        self.appSecret = appSecret
        self.redirectURI = redirectURI
    }

    public static func fromEnvironment() throws -> FacebookOAuthConfig {
        let env = ProcessInfo.processInfo.environment
        let appId = (env["FACEBOOK_APP_ID"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let appSecret = (env["FACEBOOK_APP_SECRET"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let redirectURI = (env["FACEBOOK_REDIRECT_URI"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appId.isEmpty else { throw FacebookConnectorError.invalidConfiguration("Missing FACEBOOK_APP_ID") }
        guard !appSecret.isEmpty else { throw FacebookConnectorError.invalidConfiguration("Missing FACEBOOK_APP_SECRET") }
        guard !redirectURI.isEmpty else { throw FacebookConnectorError.invalidConfiguration("Missing FACEBOOK_REDIRECT_URI") }
        return FacebookOAuthConfig(appId: appId, appSecret: appSecret, redirectURI: redirectURI)
    }
}

public struct FacebookOAuthToken: Codable, Sendable, Equatable {
    public let accessToken: String
    public let tokenType: String?
    public let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

public final class FacebookOAuthClient: @unchecked Sendable {
    private let config: FacebookOAuthConfig
    private let http: HTTPClient

    public init(config: FacebookOAuthConfig, http: HTTPClient = .init()) {
        self.config = config
        self.http = http
    }

    public func authorizationURL(state: String, scope: [String] = ["user_posts"]) throws -> URL {
        let appId = config.appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let redirectURI = config.redirectURI.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appId.isEmpty else { throw FacebookConnectorError.invalidConfiguration("Missing appId") }
        guard !redirectURI.isEmpty else { throw FacebookConnectorError.invalidConfiguration("Missing redirectURI") }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.facebook.com"
        components.path = "/\(FacebookGraph.API_VERSION)/dialog/oauth"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: appId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope.joined(separator: ","))
        ]
        guard let url = components.url else {
            throw FacebookConnectorError.invalidConfiguration("Failed to build authorization URL.")
        }
        return url
    }

    public func exchangeCodeForToken(code: String) async throws -> FacebookOAuthToken {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCode.isEmpty else {
            throw FacebookConnectorError.invalidResponseShape("Missing authorization code.")
        }

        var components = URLComponents(url: FacebookGraph.BASE_URL, resolvingAgainstBaseURL: false)
        components?.path = "/\(FacebookGraph.API_VERSION)/oauth/access_token"
        guard let url = components?.url else {
            throw FacebookConnectorError.invalidConfiguration("Failed to build token exchange URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = formURLEncodedBody([
            "client_id": config.appId,
            "redirect_uri": config.redirectURI,
            "client_secret": config.appSecret,
            "code": trimmedCode
        ])

        let (data, httpResponse) = try await http.send(request)
        if httpResponse.statusCode >= 400 {
            throw FacebookGraphClient.mapGraphError(data: data, response: httpResponse)
        }

        do {
            return try JSONDecoder().decode(FacebookOAuthToken.self, from: data)
        } catch {
            throw FacebookConnectorError.decodingFailed("Failed to decode token exchange response: \(error.localizedDescription)")
        }
    }
}

private func formURLEncodedBody(_ parameters: [String: String]) -> Data {
    let pairs = parameters
        .sorted(by: { $0.key < $1.key })
        .map { key, value in
            "\(formURLEncode(key))=\(formURLEncode(value))"
        }
        .joined(separator: "&")
    return Data(pairs.utf8)
}

private func formURLEncode(_ value: String) -> String {
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: ":#[]@!$&'()*+,;=")
    return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
}
