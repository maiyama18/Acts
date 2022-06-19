import KeychainAccess

let keychain = Keychain(service: "com.muijp.Acts")
let tokenKey = "github_token"

public struct SecureStorage {
    public var getToken: () -> String?
    public var saveToken: (String) throws -> Void
    public var removeToken: () throws -> Void
}

extension SecureStorage {
    public static let live: SecureStorage = .init(
        getToken: { try? keychain.get(tokenKey) },
        saveToken: { token in
            try keychain.set(token, key: tokenKey)
        },
        removeToken: { try keychain.remove(tokenKey) }
    )
}
