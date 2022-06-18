import UIKit

public enum Dialogs {
    public static func showSimpleError(from originVC: UIViewController, message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        originVC.present(alertController, animated: true)
    }
}
