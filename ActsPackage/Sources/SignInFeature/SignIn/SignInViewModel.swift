import Combine
import AsyncAlgorithms
import Foundation
import AuthAPI
import Core

@MainActor
final class SignInViewModel: ObservableObject {
    enum Event {
        case startAuth(url: URL)
        case completeSignIn
        case showError(message: String)
    }
    
    let events: AsyncChannel<Event> = .init()
    
    private let authAPIClient: AuthAPIClientProtocol
    private let secureStorage: SecureStorageProtocol
    
    private var state: String?
    
    init(authAPIClient: AuthAPIClientProtocol, secureStorage: SecureStorageProtocol) {
        self.authAPIClient = authAPIClient
        self.secureStorage = secureStorage
    }
    
    func onSignInButtonTapped() async {
        let state = UUID().uuidString
        self.state = state
        guard let url = makeOAuthURL(state: state) else {
            await events.send(.showError(message: "Unexpected error occurred"))
            return
        }
        await events.send(.startAuth(url: url))
    }
    
    func onCallBackReceived(url: URL) async {
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
            let token = try await authAPIClient.fetchAccessToken(code: code)
            try secureStorage.saveToken(token: token)
            await events.send(.completeSignIn)
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
