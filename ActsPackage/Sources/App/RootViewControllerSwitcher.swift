import UIKit
import SignInFeature
import Core
import ActionsFeature

@MainActor
public final class RootViewControllerSwitcher {
    private let window: UIWindow
    private let secureStorage: SecureStorage = .shared
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public func setup() {
        switchRootViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(switchRootViewController), name: .didChangeAuthState, object: nil)
    }
    
    @objc
    private func switchRootViewController() {
        if secureStorage.getToken() != nil {
            window.rootViewController = RepositoryListViewController()
        } else {
            window.rootViewController = SignInViewController()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
