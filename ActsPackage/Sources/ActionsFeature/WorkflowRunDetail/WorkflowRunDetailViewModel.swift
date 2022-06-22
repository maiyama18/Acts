import AsyncAlgorithms
import Combine
import Core
import GitHubAPI
import SwiftUI

@MainActor
public final class WorkflowRunDetailViewModel: ObservableObject {
    enum Event {
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var workflowJobs: [GitHubWorkflowJob] = []

    let events: AsyncChannel<Event> = .init()

    private let workflowRun: GitHubWorkflowRun
    private let gitHubAPIClient: GitHubAPIClientProtocol

    var title: String {
        "\(workflowRun.name) #\(workflowRun.runNumber)"
    }

    public init(
        workflowRun: GitHubWorkflowRun,
        gitHubAPIClient: GitHubAPIClientProtocol
    ) {
        self.workflowRun = workflowRun
        self.gitHubAPIClient = gitHubAPIClient
    }

    func onViewLoaded() async {
        do {
            let response = try await gitHubAPIClient.getWorkflowJobs(workflowRun: workflowRun)
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

    func onStepTapped(job: GitHubWorkflowJob, step: GitHubWorkflowStep) async {
        guard !step.hasLog else {
            for jobIndex in workflowJobs.indices {
                for stepIndex in workflowJobs[jobIndex].steps.indices {
                    guard workflowJobs[jobIndex].steps[stepIndex].id == step.id else { continue }
                    workflowJobs[jobIndex].steps[stepIndex].log = nil
                }
            }
            return
        }

        do {
            let response = try await gitHubAPIClient.getWorkflowJobsLog(workflowRun: workflowRun, jobNames: workflowJobs.map(\.name), maxLines: 100)
            guard let stepLog = response[job.name]?.stepLogs.first(where: { $0.stepNumber == step.number }) else {
                return
            }
            for jobIndex in workflowJobs.indices {
                guard workflowJobs[jobIndex].id == job.id else { continue }
                for stepIndex in workflowJobs[jobIndex].steps.indices {
                    guard workflowJobs[jobIndex].steps[stepIndex].id == step.id else { continue }
                    workflowJobs[jobIndex].steps[stepIndex].log = stepLog.log
                }
            }
        } catch {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }
}
