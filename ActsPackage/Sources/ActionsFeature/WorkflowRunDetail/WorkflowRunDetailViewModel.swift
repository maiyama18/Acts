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
        case refreshNavigationBar
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var workflowJobs: [GitHubWorkflowJob] = []

    let events: AsyncChannel<Event> = .init()

    private var workflowRun: GitHubWorkflowRun
    private let gitHubUseCase: GitHubUseCaseProtocol

    var title: String {
        workflowRun.title
    }

    var primaryAction: (label: String, action: @MainActor() async -> Void) {
        switch workflowRun.status {
        case .queued, .inProgress:
            return (label: "Cancel", action: onCancelTapped)
        default:
            return (label: "Re-run", action: onRerunTapped)
        }
    }

    public init(
        workflowRun: GitHubWorkflowRun,
        gitHubUseCase: GitHubUseCaseProtocol
    ) {
        self.workflowRun = workflowRun
        self.gitHubUseCase = gitHubUseCase
    }

    func onViewLoaded() async {
        do {
            workflowJobs = try await gitHubUseCase.getWorkflowJobs(run: workflowRun)
        } catch {
            await handleGitHubError(error: error)
        }
    }

    func onPullToRefreshed() async {
        do {
            workflowJobs = try await gitHubUseCase.getWorkflowJobs(run: workflowRun)

            workflowRun = try await gitHubUseCase.getWorkflowRun(repository: workflowRun.repository, runId: workflowRun.id)
            await events.send(.refreshNavigationBar)
        } catch {
            await handleGitHubError(error: error)
        }
    }

    func onStepTapped(step: GitHubWorkflowStep) async {
        guard let indices = findWorkflowJobsIndices(jobId: step.jobId, step: step) else {
            return
        }

        guard !step.hasLog else {
            workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .notLoaded
            return
        }

        do {
            workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .loading
            let stepLog = try await gitHubUseCase.getWorkflowStepLog(step: step, siblingSteps: findChildSteps(jobId: step.jobId), maxLines: 200)
            guard let stepLog = stepLog else {
                workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .notLoaded
                return
            }
            workflowJobs[indices.jobIndex].steps[indices.stepIndex].log = .loaded(log: stepLog.processedLog, abbreviated: stepLog.abbreviated)
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
            try await gitHubUseCase.rerunWorkflow(run: workflowRun)
            await events.send(.requestSent(action: "Re-run"))
        } catch {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }

    func onCancelTapped() async {
        do {
            try await gitHubUseCase.cancelWorkflow(run: workflowRun)
            await events.send(.requestSent(action: "Cancel"))
        } catch {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }

    func onSeeEntireLogTapped(job: GitHubWorkflowJob) async {
        guard let url = URL(string: job.htmlUrl) else { return }
        await events.send(.openOnBrowser(url: url))
    }

    private func handleGitHubError(error: Error) async {
        switch error {
        case GitHubAPIError.unauthorized:
            await events.send(.unauthorized)
        case GitHubAPIError.disconnected:
            await events.send(.showError(message: L10n.ErrorMessage.disconnected))
        default:
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }

    private func findChildSteps(jobId: Int) -> [GitHubWorkflowStep] {
        for job in workflowJobs {
            guard job.id == jobId else { continue }
            return job.steps
        }
        return []
    }

    private func findWorkflowJobsIndices(jobId: Int, step: GitHubWorkflowStep) -> (jobIndex: Int, stepIndex: Int)? {
        for jobIndex in workflowJobs.indices {
            guard workflowJobs[jobIndex].id == jobId else { continue }
            for stepIndex in workflowJobs[jobIndex].steps.indices {
                guard workflowJobs[jobIndex].steps[stepIndex].id == step.id else { continue }
                return (jobIndex, stepIndex)
            }
        }
        return nil
    }
}
