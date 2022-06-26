import ActionsFeature
import AuthAPI
import Core
import GitHub
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
            let viewModel = RepositoryListViewModel(
                gitHubUseCase: GitHubUseCase.shared,
                cacheClient: CacheClient.shared
            )
            let rootViewController = UINavigationController(rootViewController: RepositoryListViewController(viewModel: viewModel))
            rootViewController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!,
            ]
            window.rootViewController = rootViewController
        } else {
            let viewModel = SignInViewModel(
                authAPIClient: AuthAPIClient.shared,
                secureStorage: SecureStorage.shared,
                stateGenerator: StateGenerator.shared
            )
            window.rootViewController = SignInViewController(viewModel: viewModel)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
