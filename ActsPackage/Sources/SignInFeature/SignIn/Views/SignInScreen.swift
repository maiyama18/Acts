import Core
import PKHUD
import SwiftUI

struct SignInScreen: View {
    @ObservedObject var viewModel: SignInViewModel

    var body: some View {
        VStack {
            Button(action: {
                Task {
                    await viewModel.onSignInButtonTapped()
                }
            }) {
                Text(L10n.SignInFeature.signInWithGithub)
            }
        }
        .progressHUD(showing: viewModel.showingHUD)
    }
}
