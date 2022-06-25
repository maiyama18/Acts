import GitHub
import PKHUD
import SwiftUI

struct RepositoryListScreen: View {
    @ObservedObject var viewModel: RepositoryListViewModel

    var body: some View {
        List {
            Section {
                ForEach(viewModel.favoriteRepositories) { repository in
                    RepositoryView(
                        repository: repository,
                        favorited: true,
                        onTapped: {
                            Task { await viewModel.onRepositoryTapped(repository: repository) }
                        },
                        onFavoriteButtonTapped: {
                            Task { await viewModel.onUnFavorited(repository: repository) }
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } header: {
                if !viewModel.favoriteRepositories.isEmpty {
                    Text("Favorite")
                }
            }

            Section {
                ForEach(viewModel.usersRepositories) { repository in
                    RepositoryView(
                        repository: repository,
                        favorited: false,
                        onTapped: {
                            Task { await viewModel.onRepositoryTapped(repository: repository) }
                        },
                        onFavoriteButtonTapped: {
                            Task { await viewModel.onFavorited(repository: repository) }
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } header: {
                if !viewModel.usersRepositories.isEmpty {
                    Text("Your's")
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.onPullToRefreshed()
        }
        .progressHUD(showing: viewModel.showingHUD)
    }
}
