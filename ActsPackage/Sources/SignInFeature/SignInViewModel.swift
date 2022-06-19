import Combine
import AsyncAlgorithms
import Foundation
import AuthAPI

@MainActor
final class SignInViewModel: ObservableObject {
    enum Action {
        case signInButtonTapped
        case callBackReceived(url: URL)
    }
    
    enum Event {
        case startAuth(url: URL)
        case showError(message: String)
    }
    
    @Published var token: String?
    
    let events: AsyncChannel<Event> = .init()
    
    private let authAPIClient: AuthAPIClient
    private var state: String?
    
    init(authAPIClient: AuthAPIClient) {
        self.authAPIClient = authAPIClient
    }
    
    func execute(_ action: Action) {
        Task {
            switch action {
            case .signInButtonTapped:
                let state = UUID().uuidString
                self.state = state
                guard let url = makeOAuthURL(state: state) else {
                    await events.send(.showError(message: "Unexpected error occurred"))
                    return
                }
                await events.send(.startAuth(url: url))
            case .callBackReceived(let url):
                guard let state = extractQueryValue(from: url, name: "state"), state == self.state else {
                    await events.send(.showError(message: "Unexpected error occurred"))
                    return
                }
                self.state = nil
                
                guard let code = extractQueryValue(from: url, name: "code") else {
                    await events.send(.showError(message: "Unexpected error occurred"))
                    return
                }
                
                do {
                    token = try await authAPIClient.fetchAccessToken(code)
                } catch {
                    switch error {
                    case AuthAPIError.authFailed(let message):
                        await events.send(.showError(message: message))
                    case AuthAPIError.disconnected:
                        await events.send(.showError(message: "Network disconnected"))
                    default:
                        await events.send(.showError(message: "Unexpected error occurred"))
                    }
                    return
                }
            }
        }
    }
    
    private func makeOAuthURL(state: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = "/login/oauth/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "1415cc176e9e70ed3825"),
            URLQueryItem(name: "scope", value: "repo"),
            URLQueryItem(name: "state", value: state)
        ]

        return components.url
    }
    
    private func extractQueryValue(from url: URL, name: String) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == name })?.value
    }
}
