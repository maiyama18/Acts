import Core
@testable import SettingsFeature
import XCTest

@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var viewModel: SettingsViewModel!

    private var secureStorage: SecureStorageProtocolMock!

    @MainActor
    override func setUp() {
        super.setUp()

        secureStorage = SecureStorageProtocolMock()

        viewModel = SettingsViewModel(secureStorage: secureStorage)
    }

    func test_onSignOutButtonTapped_success() async throws {
        var eventsIterator = viewModel.events.makeAsyncIterator()

        Task {
            await viewModel.onSignOutButtonTapped()
        }

        try await XCTAssertEqualAsync(await eventsIterator.next(), .completeSignOut)
        XCTAssertEqual(secureStorage.removeTokenCallCount, 1)
    }

    func test_onSignOutButtonTapped_failure() async throws {
        var eventsIterator = viewModel.events.makeAsyncIterator()

        secureStorage.removeTokenHandler = {
            throw DummyError()
        }

        Task {
            await viewModel.onSignOutButtonTapped()
        }

        try await XCTAssertEqualAsync(await eventsIterator.next(), .showError(message: L10n.ErrorMessage.signOutFailed))
    }
}
