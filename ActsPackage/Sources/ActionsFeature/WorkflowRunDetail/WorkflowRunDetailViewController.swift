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
    }

    private func setupNavigation() {
        navigationItem.title = viewModel.title
    }

    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {
                switch event {}
            }
        }
    }
}
