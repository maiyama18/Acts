import AsyncAlgorithms
import AuthAPI
import Combine
import Core
import Foundation

@MainActor
public final class SignInViewModel: ObservableObject {
    enum Event: Equatable {
        case startAuth(url: URL)
        case completeSignIn
        case showError(message: String)
    }

    @Published private(set) var showingHUD: Bool = false

    let events: AsyncChannel<Event> = .init()

    private let authAPIClient: AuthAPIClientProtocol
    private let secureStorage: SecureStorageProtocol
    private let stateGenerator: StateGeneratorProtocol

    private var state: String?

    public init(
        authAPIClient: AuthAPIClientProtocol,
        secureStorage: SecureStorageProtocol,
        stateGenerator: StateGeneratorProtocol
    ) {
        self.authAPIClient = authAPIClient
        self.secureStorage = secureStorage
        self.stateGenerator = stateGenerator
    }

    func onSignInButtonTapped() async {
        let state = stateGenerator.generate()
        self.state = state
        guard let url = makeOAuthURL(state: state) else {
            await events.send(.showError(message: "Unexpected error occurred"))
            return
        }
        await events.send(.startAuth(url: url))
    }

    func onCallBackReceived(url: URL?) async {
        guard let url = url else {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
            return
        }

        guard let state = extractQueryValue(from: url, name: "state"), state == self.state else {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
            return
        }
        self.state = nil

        guard let code = extractQueryValue(from: url, name: "code") else {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
            return
        }

        showingHUD = true
        defer {
            showingHUD = false
        }
        do {
            let token = try await authAPIClient.fetchAccessToken(code: code)
            try secureStorage.saveToken(token: token)
            await events.send(.completeSignIn)
        } catch {
            switch error {
            case let AuthAPIError.authFailed(message):
                await events.send(.showError(message: message))
            case AuthAPIError.disconnected:
                await events.send(.showError(message: L10n.ErrorMessage.disconnected))
            default:
                await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
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
            URLQueryItem(name: "state", value: state),
        ]

        return components.url
    }

    private func extractQueryValue(from url: URL, name: String) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == name })?.value
    }
}
