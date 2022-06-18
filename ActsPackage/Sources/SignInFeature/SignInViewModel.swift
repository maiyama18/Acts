import Combine
import AsyncAlgorithms

final class SignInViewModel: ObservableObject {
    enum Action {
        case signInButtonTapped
    }
    
    enum Event {
        case startAuth
    }
    
    let events: AsyncChannel<Event> = .init()
    
    func execute(_ action: Action) {
        Task {
            switch action {
            case .signInButtonTapped:
                await events.send(.startAuth)
            }
        }
    }
}
