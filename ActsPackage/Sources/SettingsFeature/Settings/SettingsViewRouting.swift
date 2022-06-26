import UIKit

public protocol SettingsViewRouting {
    func presentSettingsView(from originVC: UIViewController)
}

public extension SettingsViewRouting {
    func presentSettingsView(from originVC: UIViewController) {
        let destinationVC = UINavigationController(rootViewController: SettingsViewController())
        destinationVC.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!,
        ]
        originVC.present(destinationVC, animated: true)
    }
}
