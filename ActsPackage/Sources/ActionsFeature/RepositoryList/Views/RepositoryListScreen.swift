import SwiftUI

struct RepositoryListScreen: View {
    @ObservedObject var viewModel: RepositoryListViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    await viewModel.onSignOutButtonTapped()
                }
            }) {
                Text("Sign Out from GitHub")
            }
            
            List {
                ForEach(viewModel.repositories) { repository in
                    Text(repository.name)
                }
            }
        }
    }
}
