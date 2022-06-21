import AsyncAlgorithms
import AuthAPI
import Core
@testable import SignInFeature
import XCTest

@MainActor
final class SignInViewModelTests: XCTestCase {
    private var viewModel: SignInViewModel!

    private var authAPIClient: AuthAPIClientProtocolMock!
    private var secureStorage: SecureStorageProtocolMock!
    private var stateGenerator: StateGeneratorProtocolMock!

    private let dummyState = "dummy-state"
    private let dummyCode = "dummy-code"
    private let dummyToken = "dummy-token"

    @MainActor
    override func setUp() {
        super.setUp()

        authAPIClient = AuthAPIClientProtocolMock()
        secureStorage = SecureStorageProtocolMock()
        stateGenerator = StateGeneratorProtocolMock()

        viewModel = SignInViewModel(
            authAPIClient: authAPIClient,
            secureStorage: secureStorage,
            stateGenerator: stateGenerator
        )
    }

    func test_onSignInButtonTapped_success() async throws {
        var eventsIterator = viewModel.events.makeAsyncIterator()

        stateGenerator.generateHandler = { self.dummyState }

        Task {
            await viewModel.onSignInButtonTapped()
        }

        guard case let .startAuth(url) = await eventsIterator.next() else {
            XCTFail("event is expected be .startAuth")
            return
        }
        XCTAssertEqual(url.path, "/login/oauth/authorize")
        XCTAssertEqual(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "state" })?.value, dummyState)
    }

    func test_onCallBackReceived_success() async throws {
        var eventsIterator = viewModel.events.makeAsyncIterator()
        var showingHUDIterator = viewModel.$showingHUD.iterator()

        stateGenerator.generateHandler = { self.dummyState }
        authAPIClient.fetchAccessTokenHandler = { code in
            guard code == self.dummyCode else {
                XCTFail("code was expected be \(self.dummyCode), but got \(code)")
                return ""
            }
            return self.dummyToken
        }

        // preparation
        Task {
            await viewModel.onSignInButtonTapped()
        }
        let _ = await eventsIterator.next()

        Task {
            await viewModel.onCallBackReceived(url: URL(string: "acts://github.callback?state=\(dummyState)&code=\(dummyCode)")!)
        }

        try await XCTAssertEqualAsync(await showingHUDIterator.next(), true)
        try await XCTAssertEqualAsync(await eventsIterator.next(), .completeSignIn)
        try await XCTAssertEqualAsync(await showingHUDIterator.next(), false)
        XCTAssertEqual(secureStorage.saveTokenArgValues, [dummyToken])
    }

    func test_onCallBackReceived_failure_urlNil() async throws {
        var eventsIterator = viewModel.events.makeAsyncIterator()

        Task {
            await viewModel.onCallBackReceived(url: nil)
        }

        try await XCTAssertEqualAsync(await eventsIterator.next(), .showError(message: L10n.ErrorMessage.unexpectedError))
    }

    func test_onCallBackReceived_failure_stateWrong() async throws {
        var eventsIterator = viewModel.events.makeAsyncIterator()

        stateGenerator.generateHandler = { self.dummyState }
        authAPIClient.fetchAccessTokenHandler = { code in
            guard code == self.dummyCode else {
                XCTFail("code was expected be \(self.dummyCode), but got \(code)")
                return ""
            }
            return self.dummyToken
        }

        // preparation
        Task {
            await viewModel.onSignInButtonTapped()
        }
        let _ = await eventsIterator.next()

        Task {
            await viewModel.onCallBackReceived(url: URL(string: "acts://github.callback?state=\("wrong-state")&code=\(dummyCode)")!)
        }

        try await XCTAssertEqualAsync(await eventsIterator.next(), .showError(message: L10n.ErrorMessage.unexpectedError))
    }

    func test_onCallBackReceived_failure_apiError() async throws {
        var eventsIterator = viewModel.events.makeAsyncIterator()
        var showingHUDIterator = viewModel.$showingHUD.iterator()

        stateGenerator.generateHandler = { self.dummyState }
        authAPIClient.fetchAccessTokenHandler = { _ in
            throw AuthAPIError.authFailed(message: "dummy message")
        }

        // preparation
        Task {
            await viewModel.onSignInButtonTapped()
        }
        let _ = await eventsIterator.next()

        Task {
            await viewModel.onCallBackReceived(url: URL(string: "acts://github.callback?state=\(dummyState)&code=\(dummyCode)")!)
        }

        try await XCTAssertEqualAsync(await showingHUDIterator.next(), true)
        try await XCTAssertEqualAsync(await eventsIterator.next(), .showError(message: "dummy message"))
        try await XCTAssertEqualAsync(await showingHUDIterator.next(), false)
    }
}
