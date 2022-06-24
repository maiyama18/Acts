import ActionsFeature
import AuthAPI
import Core
import GitHub
import GitHubAPI
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
                secureStorage: SecureStorage.shared
            )
            window.rootViewController = UINavigationController(rootViewController: RepositoryListViewController(viewModel: viewModel))
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
