import Core
import PKHUD
import SwiftUI

struct SignInScreen: View {
    @ObservedObject var viewModel: SignInViewModel

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "link")
                .font(.system(size: 120).bold())

            Text("Acts")
                .font(.custom("AvenirNext-Bold", size: 54))

            Spacer()

            Button(action: {
                Task {
                    await viewModel.onSignInButtonTapped()
                }
            }) {
                Text(L10n.SignInFeature.signInWithGithub)
                    .font(.body.bold())
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .label))
                    .cornerRadius(16)
                    .padding()
            }

            Spacer()
                .frame(height: 48)
        }
        .progressHUD(showing: viewModel.showingHUD)
    }
}
