import Foundation

/// @mockable
public protocol StateGeneratorProtocol {
    func generate() -> String
}

public final class StateGenerator: StateGeneratorProtocol {
    public static let shared: StateGenerator = .init()

    private init() {}

    public func generate() -> String {
        UUID().uuidString
    }
}
