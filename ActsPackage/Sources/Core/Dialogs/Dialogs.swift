import UIKit

public enum Dialogs {
    public static func showSimpleMessage(from originVC: UIViewController, message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: L10n.Common.ok, style: .default))
        originVC.present(alertController, animated: true)
    }

    public static func showSimpleError(from originVC: UIViewController, message: String) {
        let alertController = UIAlertController(title: L10n.Common.error, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: L10n.Common.ok, style: .default))
        originVC.present(alertController, animated: true)
    }
}
