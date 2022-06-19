import PKHUD
import SwiftUI

public extension View {
    func progressHUD(showing: Bool) -> some View {
        onChange(of: showing) { showing in
            if showing {
                HUD.show(.progress)
            } else {
                HUD.hide()
            }
        }
    }
}
