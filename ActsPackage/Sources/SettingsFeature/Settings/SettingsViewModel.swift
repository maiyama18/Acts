import AsyncAlgorithms
import Combine
import Core
import Foundation

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

    var versionString: String {
        Bundle.main.appVersion
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
