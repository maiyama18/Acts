import UIKit

public protocol SettingsViewRouting {
    func presentSettingsView(from originVC: UIViewController)
}

public extension SettingsViewRouting {
    func presentSettingsView(from originVC: UIViewController) {
        let destinationVC = SettingsViewController()
        originVC.present(destinationVC, animated: true)
    }
}
