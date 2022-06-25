import GitHub
import PKHUD
import SwiftUI

struct RepositoryListScreen: View {
    @ObservedObject var viewModel: RepositoryListViewModel

    var body: some View {
        List {
            Section {
                ForEach(viewModel.repositories) { repository in
                    RepositoryView(repository: repository)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                await viewModel.onRepositoryTapped(repository: repository)
                            }
                        }
                }
            } header: {
                Text("Your's")
            }
        }
        .listStyle(.plain)
        .progressHUD(showing: viewModel.showingHUD)
    }
}
