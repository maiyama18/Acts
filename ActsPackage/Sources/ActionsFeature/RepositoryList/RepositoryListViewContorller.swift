import Core
import GitHubAPI
import UIKit

public final class RepositoryListViewController: UIViewController {
    private let viewModel: RepositoryListViewModel
    private var eventSubscription: Task<Void, Never>?

    @MainActor
    public init() {
        viewModel = .init(gitHubAPIClient: GitHubAPIClient.shared, secureStorage: SecureStorage.shared)

        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        eventSubscription?.cancel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        subscribe()
        hostSwiftUIView(RepositoryListScreen(viewModel: viewModel))

        Task {
            await viewModel.onViewLoaded()
        }
    }

    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {
                switch event {
                case .completeSignOut:
                    NotificationCenter.default.post(name: .didChangeAuthState, object: nil)
                case .unauthorized:
                    NotificationCenter.default.post(name: .didChangeAuthState, object: nil)
                case let .showError(message):
                    Dialogs.showSimpleError(from: self, message: message)
                }
            }
        }
    }
}
