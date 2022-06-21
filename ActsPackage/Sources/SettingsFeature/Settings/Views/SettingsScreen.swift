import Core
import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Button(action: {
            Task {
                await viewModel.onSignOutButtonTapped()
            }
        }) {
            Text(L10n.SettingsFeature.signOutFromGithub)
        }
    }
}
