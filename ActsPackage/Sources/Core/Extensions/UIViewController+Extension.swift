import SwiftUI

public extension UIViewController {
    func hostSwiftUIView<Content: View>(_ rootView: Content) {
        let hostingVC = UIHostingController(rootView: rootView)
        addChild(hostingVC)
        hostingVC.didMove(toParent: self)
        view.addSubview(hostingVC.view)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVC.view.pinEdgesToSuperView()
    }
}
