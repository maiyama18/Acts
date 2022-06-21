import KeychainAccess

let keychain = Keychain(service: "com.muijp.Acts")
let tokenKey = "github_token"

/// @mockable
public protocol SecureStorageProtocol {
    func getToken() -> String?
    func saveToken(token: String) throws
    func removeToken() throws
}

public final class SecureStorage: SecureStorageProtocol {
    public static let shared: SecureStorage = .init()

    private init() {}

    public func getToken() -> String? {
        try? keychain.get(tokenKey)
    }

    public func saveToken(token: String) throws {
        try keychain.set(token, key: tokenKey)
    }

    public func removeToken() throws {
        try keychain.remove(tokenKey)
    }
}
