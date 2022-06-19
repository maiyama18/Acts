import SwiftUI

struct RepositoryListScreen: View {
    @ObservedObject var viewModel: RepositoryListViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.execute(.signOutButtonTapped)
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
