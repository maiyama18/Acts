import GitHub
import UIKit

@MainActor
public protocol WorkflowRunListRouting {
    func pushWorkflowRunListView(from originVC: UIViewController, repository: GitHubRepository)
}

public extension WorkflowRunListRouting {
    func pushWorkflowRunListView(from originVC: UIViewController, repository: GitHubRepository) {
        let viewModel = WorkflowRunListViewModel(
            repository: repository,
            gitHubUseCase: GitHubUseCase.shared
        )
        let destinationVC = WorkflowRunListViewController(viewModel: viewModel)
        originVC.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
