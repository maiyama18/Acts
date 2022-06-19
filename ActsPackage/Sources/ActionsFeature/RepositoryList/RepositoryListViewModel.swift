import AsyncAlgorithms
import Combine
import Core
import GitHubAPI

@MainActor
final class RepositoryListViewModel: ObservableObject {
    enum Action {
        case viewLoaded
        case signOutButtonTapped
    }
    
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
    
    func execute(_ action: Action) {
        Task {
            switch action {
            case .viewLoaded:
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
            case .signOutButtonTapped:
                do {
                    try secureStorage.removeToken()
                    await events.send(.completeSignOut)
                } catch {
                    await events.send(.showError(message: "Unexpected error occurred"))
                }
            }
        }
    }
}
