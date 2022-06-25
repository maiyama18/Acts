import GitHub
import GitHubAPI
import UIKit

@MainActor
protocol WorkflowRunDetailRouting {
    func pushWorkflowRunDetail(from originVC: UIViewController, workflowRun: GitHubWorkflowRunResponse)
}

extension WorkflowRunDetailRouting {
    func pushWorkflowRunDetail(from originVC: UIViewController, workflowRun: GitHubWorkflowRunResponse) {
        let viewModel = WorkflowRunDetailViewModel(
            workflowRun: workflowRun,
            gitHubUseCase: GitHubUseCase.shared
        )
        let destinationVC = WorkflowRunDetailViewController(
            viewModel: viewModel
        )
        originVC.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
