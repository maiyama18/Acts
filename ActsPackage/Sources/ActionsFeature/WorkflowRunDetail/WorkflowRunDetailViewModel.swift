import AsyncAlgorithms
import Combine
import Core
import GitHub
import GitHubAPI
import SwiftUI

@MainActor
public final class WorkflowRunDetailViewModel: ObservableObject {
    enum Event {
        case requestSent(action: String)
        case openOnBrowser(url: URL)
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var workflowJobs: [GitHubWorkflowJobResponse] = []

    let events: AsyncChannel<Event> = .init()

    private let workflowRun: GitHubWorkflowRunResponse
    private let gitHubUseCase: GitHubUseCaseProtocol

    var title: String {
        "\(workflowRun.name) #\(workflowRun.runNumber)"
    }

    var primaryAction: (label: String, action: @MainActor() async -> Void) {
        switch workflowRun.runStatus {
        case .queued, .inProgress:
            return (label: "Cancel", action: onCancelTapped)
        default:
            return (label: "Re-run", action: onRerunTapped)
        }
    }

    public init(
        workflowRun: GitHubWorkflowRunResponse,
        gitHubUseCase: GitHubUseCaseProtocol
    ) {
        self.workflowRun = workflowRun
        self.gitHubUseCase = gitHubUseCase
    }

    func onViewLoaded() async {
        do {
            let response = try await gitHubUseCase.getWorkflowJobs(workflowRun: workflowRun)
            workflowJobs = response.jobs
        } catch {
            switch error {
            case GitHubAPIError.unauthorized:
                await events.send(.unauthorized)
            case GitHubAPIError.disconnected:
                await events.send(.showError(message: L10n.ErrorMessage.disconnected))
            default:
                await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
            }
        }
    }

    func onStepTapped(job: GitHubWorkflowJobResponse, step: GitHubWorkflowStepResponse) async {
        guard let indices = findWorkflowJobsIndices(job: job, step: step) else {
            return
        }

        guard !step.hasLog else {
            workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .notLoaded
            return
        }

        do {
            workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .loading
            let stepLog = try await gitHubUseCase.getWorkflowStepLog(step: step, logsUrl: workflowRun.logsUrl, maxLines: 100)
            guard let stepLog = stepLog else {
                workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .notLoaded
                return
            }
            workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .loaded(log: stepLog.log, abbreviated: stepLog.abbreviated)
        } catch {
            workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .notLoaded
            switch error {
            case GitHubAPIError.notFound:
                await events.send(.showError(message: L10n.ErrorMessage.logUnavailable))
            default:
                await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
            }
        }
    }

    func onRerunTapped() async {
        do {
            try await gitHubUseCase.rerunWorkflow(workflowRun: workflowRun)
            await events.send(.requestSent(action: "Re-run"))
        } catch {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }

    func onCancelTapped() async {
        do {
            try await gitHubUseCase.cancelWorkflow(workflowRun: workflowRun)
            await events.send(.requestSent(action: "Cancel"))
        } catch {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }

    func onSeeEntireLogTapped(job: GitHubWorkflowJobResponse) async {
        guard let url = URL(string: job.htmlUrl) else { return }
        await events.send(.openOnBrowser(url: url))
    }

    private func findWorkflowJobsIndices(job: GitHubWorkflowJobResponse, step: GitHubWorkflowStepResponse) -> (jobIndex: Int, stepIndex: Int)? {
        for jobIndex in workflowJobs.indices {
            guard workflowJobs[jobIndex].id == job.id else { continue }
            for stepIndex in workflowJobs[jobIndex].steps.indices {
                guard workflowJobs[jobIndex].steps[stepIndex].id == step.id else { continue }
                return (jobIndex, stepIndex)
            }
        }
        return nil
    }
}
