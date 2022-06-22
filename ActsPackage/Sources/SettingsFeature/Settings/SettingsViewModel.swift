import AsyncAlgorithms
import Combine
import Core

final class SettingsViewModel: ObservableObject {
    enum Event: Equatable {
        case completeSignOut
        case showError(message: String)
    }

    let events: AsyncChannel<Event> = .init()

    private let secureStorage: SecureStorageProtocol

    init(secureStorage: SecureStorageProtocol) {
        self.secureStorage = secureStorage
    }

    func onSignOutButtonTapped() async {
        do {
            try secureStorage.removeToken()
            await events.send(.completeSignOut)
        } catch {
            logger.notice("Failed to removeToken for sign out: \(error.localizedDescription, privacy: .public)")
            await events.send(.showError(message: L10n.ErrorMessage.signOutFailed))
        }
    }
}
