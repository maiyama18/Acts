import UIKit
import SignInFeature

public final class RootViewControllerSwitcher {
    private let window: UIWindow
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public func setup() {
        let viewController = SignInViewController()
        window.rootViewController = viewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
