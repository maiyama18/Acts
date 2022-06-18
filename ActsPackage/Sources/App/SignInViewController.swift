import UIKit

public final class SignInViewController: UIViewController {
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        view.backgroundColor = .systemMint
    }
}
