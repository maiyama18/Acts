import GitHubAPI
import UIKit

@MainActor
public protocol WorkflowRunListRouting {
    func pushWorkflowRunListView(from originVC: UIViewController, repository: GitHubRepository)
}

public extension WorkflowRunListRouting {
    func pushWorkflowRunListView(from originVC: UIViewController, repository: GitHubRepository) {
        let viewModel = WorkflowRunListViewModel(
            repository: repository,
            gitHubAPIClient: GitHubAPIClient.shared
        )
        let destinationVC = WorkflowRunListViewController(viewModel: viewModel)
        originVC.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
