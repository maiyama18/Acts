import ActionsFeature
import Core
import SignInFeature
import UIKit

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
            window.rootViewController = UINavigationController(rootViewController: RepositoryListViewController())
        } else {
            window.rootViewController = SignInViewController()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
