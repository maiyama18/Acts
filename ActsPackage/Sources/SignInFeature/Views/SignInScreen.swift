import SwiftUI

struct SignInScreen: View {
    var viewModel: SignInViewModel
    
    var body: some View {
        Button(action: {
            viewModel.execute(.signInButtonTapped)
        }) {
            Text("Sign In with GitHub")
        }
    }
}
