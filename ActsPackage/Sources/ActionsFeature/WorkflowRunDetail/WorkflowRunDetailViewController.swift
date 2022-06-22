import Core
import UIKit

final class WorkflowRunDetailViewController: UIViewController {
    private let viewModel: WorkflowRunDetailViewModel
    private var eventSubscription: Task<Void, Never>?

    @MainActor
    init(
        viewModel: WorkflowRunDetailViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        eventSubscription?.cancel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        subscribe()
        hostSwiftUIView(WorkflowRunDetailScreen(viewModel: viewModel))

        Task {
            await viewModel.onViewLoaded()
        }
    }

    private func setupNavigation() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = .init(
            title: viewModel.primaryAction.label,
            style: .plain,
            target: self,
            action: #selector(didPrimaryActionButtonTapped)
        )
    }

    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {
                switch event {
                case let .requestSent(action):
                    Dialogs.showSimpleMessage(
                        from: self,
                        message: L10n.ActionsFeature.Message.workflowRequestSent(action)
                    )
                case .unauthorized:
                    NotificationCenter.default.post(name: .didChangeAuthState, object: nil)
                case let .showError(message):
                    Dialogs.showSimpleError(from: self, message: message)
                }
            }
        }
    }

    @objc
    private func didPrimaryActionButtonTapped() {
        Task {
            await viewModel.primaryAction.action()
        }
    }
}
