import Core
import UIKit

public final class SettingsViewController: UIViewController {
    private let viewModel: SettingsViewModel
    private var eventSubscription: Task<Void, Never>?

    public init() {
        viewModel = .init(secureStorage: SecureStorage.shared)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        eventSubscription?.cancel()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()

        subscribe()
        hostSwiftUIView(SettingsScreen(viewModel: viewModel))
    }

    private func setupNavigation() {
        navigationItem.title = L10n.SettingsFeature.Title.settings
    }

    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {
                switch event {
                case .completeSignOut:
                    NotificationCenter.default.post(name: .didChangeAuthState, object: nil)
                case let .showError(message):
                    Dialogs.showSimpleError(from: self, message: message)
                }
            }
        }
    }
}
