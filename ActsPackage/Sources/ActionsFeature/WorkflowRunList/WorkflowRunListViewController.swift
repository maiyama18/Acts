import Core
import UIKit

@MainActor
public final class WorkflowRunListViewController: UIViewController {
    private let viewModel: WorkflowRunListViewModel
    private var eventSubscription: Task<Void, Never>?

    @MainActor
    public init(viewModel: WorkflowRunListViewModel) {
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

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        subscribe()
        hostSwiftUIView(WorkflowRunListView(viewModel: viewModel))

        Task {
            await viewModel.onViewLoaded()
        }
    }

    private func setupNavigation() {
        navigationItem.backButtonTitle = ""
        navigationItem.title = viewModel.title
    }

    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {
                switch event {
                case let .showWorkflowRun(workflowRun):
                    pushWorkflowRunDetail(from: self, workflowRun: workflowRun)
                case .unauthorized:
                    NotificationCenter.default.post(name: .didChangeAuthState, object: nil)
                case let .showError(message):
                    Dialogs.showSimpleError(from: self, message: message)
                }
            }
        }
    }
}

extension WorkflowRunListViewController:
    WorkflowRunDetailRouting {}
