public protocol FacebookConnectorLogger: Sendable {
    func info(_ message: String)
    func warn(_ message: String)
    func error(_ message: String)
}

public struct FacebookNullLogger: FacebookConnectorLogger, Sendable {
    public init() {}
    public func info(_ message: String) {}
    public func warn(_ message: String) {}
    public func error(_ message: String) {}
}
