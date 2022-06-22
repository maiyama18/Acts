import AsyncAlgorithms
import Combine
import GitHubAPI

@MainActor
public final class WorkflowRunListViewModel: ObservableObject {
    enum Event {}

    let events: AsyncChannel<Event> = .init()

    private let repository: GitHubRepository
    private let gitHubAPIClient: GitHubAPIClientProtocol

    init(
        repository: GitHubRepository,
        gitHubAPIClient: GitHubAPIClientProtocol
    ) {
        self.repository = repository
        self.gitHubAPIClient = gitHubAPIClient
    }
}
