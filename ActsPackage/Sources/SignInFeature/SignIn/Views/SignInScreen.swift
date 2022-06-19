import SwiftUI
import PKHUD

struct SignInScreen: View {
    @ObservedObject var viewModel: SignInViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    await viewModel.onSignInButtonTapped()
                }
            }) {
                Text("Sign In with GitHub")
            }
        }
        .progressHUD(showing: viewModel.showingHUD)
    }
}
