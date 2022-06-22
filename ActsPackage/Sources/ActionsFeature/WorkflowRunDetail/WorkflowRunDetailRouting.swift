import GitHubAPI
import UIKit

@MainActor
protocol WorkflowRunDetailRouting {
    func pushWorkflowRunDetail(from originVC: UIViewController, workflowRun: GitHubWorkflowRun)
}

extension WorkflowRunDetailRouting {
    func pushWorkflowRunDetail(from originVC: UIViewController, workflowRun: GitHubWorkflowRun) {
        let viewModel = WorkflowRunDetailViewModel(
            workflowRun: workflowRun,
            gitHubAPIClient: GitHubAPIClient.shared
        )
        let destinationVC = WorkflowRunDetailViewController(
            viewModel: viewModel
        )
        originVC.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
