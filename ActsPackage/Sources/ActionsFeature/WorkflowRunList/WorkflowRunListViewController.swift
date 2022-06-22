import GitHubAPI
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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        subscribe()
        hostSwiftUIView(WorkflowRunListView(viewModel: viewModel))
    }

    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {}
        }
    }
}
