///
/// @Generated by Mockolo
///



import AuthAPI
import Core
import Foundation
import KeychainAccess


public class StateGeneratorProtocolMock: StateGeneratorProtocol {
    public init() { }


    public private(set) var generateCallCount = 0
    public var generateHandler: (() -> (String))?
    public func generate() -> String {
        generateCallCount += 1
        if let generateHandler = generateHandler {
            return generateHandler()
        }
        return ""
    }
}

public class AuthAPIClientProtocolMock: AuthAPIClientProtocol {
    public init() { }


    public private(set) var fetchAccessTokenCallCount = 0
    public var fetchAccessTokenArgValues = [String]()
    public var fetchAccessTokenHandler: ((String) async throws -> (String))?
    public func fetchAccessToken(code: String) async throws -> String {
        fetchAccessTokenCallCount += 1
        fetchAccessTokenArgValues.append(code)
        if let fetchAccessTokenHandler = fetchAccessTokenHandler {
            return try await fetchAccessTokenHandler(code)
        }
        return ""
    }
}

public class SecureStorageProtocolMock: SecureStorageProtocol {
    public init() { }


    public private(set) var getTokenCallCount = 0
    public var getTokenHandler: (() -> (String?))?
    public func getToken() -> String? {
        getTokenCallCount += 1
        if let getTokenHandler = getTokenHandler {
            return getTokenHandler()
        }
        return nil
    }

    public private(set) var saveTokenCallCount = 0
    public var saveTokenArgValues = [String]()
    public var saveTokenHandler: ((String) throws -> ())?
    public func saveToken(token: String) throws  {
        saveTokenCallCount += 1
        saveTokenArgValues.append(token)
        if let saveTokenHandler = saveTokenHandler {
            try saveTokenHandler(token)
        }
        
    }

    public private(set) var removeTokenCallCount = 0
    public var removeTokenHandler: (() throws -> ())?
    public func removeToken() throws  {
        removeTokenCallCount += 1
        if let removeTokenHandler = removeTokenHandler {
            try removeTokenHandler()
        }
        
    }
}
