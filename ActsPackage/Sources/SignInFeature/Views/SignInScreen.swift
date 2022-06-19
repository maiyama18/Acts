import SwiftUI

struct SignInScreen: View {
    @ObservedObject var viewModel: SignInViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.execute(.signInButtonTapped)
            }) {
                Text("Sign In with GitHub")
            }
            
            Text("token: \(viewModel.token ?? "nil")")
        }
    }
}
