import AsyncAlgorithms
import Combine
import Core

final class RepositoryListViewModel: ObservableObject {
    enum Action {
        case signOutButtonTapped
    }
    
    enum Event {
        case completeSignOut
        case showError(message: String)
    }
    
    let events: AsyncChannel<Event> = .init()
    
    private let secureStorage: SecureStorage
    
    init(secureStorage: SecureStorage) {
        self.secureStorage = secureStorage
    }
    
    func execute(_ action: Action) {
        Task {
            switch action {
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
