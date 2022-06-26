import UIKit

public protocol SettingsViewRouting {
    func presentSettingsView(from originVC: UIViewController)
}

public extension SettingsViewRouting {
    func presentSettingsView(from originVC: UIViewController) {
        let destinationVC = UINavigationController(rootViewController: SettingsViewController())
        originVC.present(destinationVC, animated: true)
    }
}
