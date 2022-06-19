import AsyncAlgorithms
import Combine
import Core
import GitHubAPI

@MainActor
final class RepositoryListViewModel: ObservableObject {
    enum Event {
        case completeSignOut
        case unauthorized
        case showError(message: String)
    }
    
    @Published private(set) var repositories: [GitHubRepository] = []
    
    let events: AsyncChannel<Event> = .init()
    
    private let gitHubAPIClient: GitHubAPIClientProtocol
    private let secureStorage: SecureStorageProtocol
    
    init(gitHubAPIClient: GitHubAPIClientProtocol, secureStorage: SecureStorageProtocol) {
        self.gitHubAPIClient = gitHubAPIClient
        self.secureStorage = secureStorage
    }
    
    func onViewLoaded() async {
        do {
            repositories = try await gitHubAPIClient.getRepositories()
        } catch {
            switch error {
            case GitHubAPIError.unauthorized:
                await events.send(.unauthorized)
            case GitHubAPIError.disconnected:
                await events.send(.showError(message: "Network disconnected"))
            default:
                await events.send(.showError(message: "Unexpected error occurred"))
            }
        }
    }
    
    func onSignOutButtonTapped() async {
        do {
            try secureStorage.removeToken()
            await events.send(.completeSignOut)
        } catch {
            await events.send(.showError(message: "Unexpected error occurred"))
        }
    }
}
