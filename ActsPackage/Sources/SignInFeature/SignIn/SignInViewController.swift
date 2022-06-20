import AuthAPI
import AuthenticationServices
import Core
import UIKit

public final class SignInViewController: UIViewController {
    private let viewModel: SignInViewModel
    private var eventSubscription: Task<Void, Never>?

    @MainActor
    public init() {
        viewModel = .init(authAPIClient: AuthAPIClient.shared, secureStorage: SecureStorage.shared)

        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        eventSubscription?.cancel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        subscribe()
        hostSwiftUIView(SignInScreen(viewModel: viewModel))
    }

    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {
                switch event {
                case let .startAuth(url):
                    Task {
                        do {
                            let callbackURL = try await ASWebAuthenticationSession.start(url: url, callbackURLScheme: "acts", presentationContextProvider: self)
                            await self.viewModel.onCallBackReceived(url: callbackURL)
                        } catch {
                            logger.notice("Failed to authenticate: \(error.localizedDescription, privacy: .public)")
                        }
                    }
                case .completeSignIn:
                    NotificationCenter.default.post(name: .didChangeAuthState, object: nil)
                case let .showError(message):
                    Dialogs.showSimpleError(from: self, message: message)
                }
            }
        }
    }
}

extension SignInViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}
