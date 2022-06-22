import PKHUD
import SwiftUI

struct RepositoryListScreen: View {
    @ObservedObject var viewModel: RepositoryListViewModel

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.repositories) { repository in
                    Text(repository.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                await viewModel.onRepositoryTapped(repository: repository)
                            }
                        }
                }
            }
        }
        .progressHUD(showing: viewModel.showingHUD)
    }
}
