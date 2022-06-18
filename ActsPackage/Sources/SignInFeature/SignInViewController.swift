import UIKit
import Core

public final class SignInViewController: UIViewController {
    private let viewModel: SignInViewModel
    private var eventSubscription: Task<Void, Never>?
    
    public init() {
        viewModel = .init()
        
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
        eventSubscription = Task { [events = viewModel.events] in
            for await event in events {
                switch event {
                case .startAuth:
                    print("Start Auth")
                }
            }
        }
    }
}
