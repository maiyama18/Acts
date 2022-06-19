import UIKit
import AuthenticationServices
import Core

public final class SignInViewController: UIViewController {
    private let viewModel: SignInViewModel
    private var eventSubscription: Task<Void, Never>?
    
    @MainActor
    public init() {
        viewModel = .init(authAPIClient: .live, secureStorage: .live)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        eventSubscription?.cancel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribe()
        hostSwiftUIView(SignInScreen(viewModel: viewModel))
    }
    
    private func subscribe() {
        eventSubscription = Task { [weak self] in
            guard let self = self else { return }
            for await event in self.viewModel.events {
                switch event {
                case .startAuth(let url):
                    let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "acts") { callbackURL, error in
                        if let error = error {
                            print("Failed to authenticate: \(error)")
                            return
                        }
                        guard let callbackURL = callbackURL else {
                            print("Failed to authenticate: callbackURL is nil")
                            return
                        }
                        self.viewModel.execute(.callBackReceived(url: callbackURL))
                    }
                    session.presentationContextProvider = self
                    session.start()
                case .completeSignIn:
                    NotificationCenter.default.post(name: .didChangeAuthState, object: nil)
                case .showError(let message):
                    Dialogs.showSimpleError(from: self, message: message)
                }
            }
        }
    }
}

extension SignInViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}
