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
                        .font(.avenirCallout.weight(.semibold))
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
                        .font(.avenirCallout.weight(.semibold))
                }
            }

            if viewModel.hasMoreUsersRepositories {
                Button(action: {
                    Task {
                        await viewModel.onLoadMoreUsersRepositoriesTapped()
                    }
                }) {
                    Group {
                        if viewModel.loadingMore {
                            ProgressView()
                        } else {
                            Text("Load more")
                                .foregroundColor(.accentColor)
                                .bold()
                        }
                    }
                    .font(.avenirCallout)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.onPullToRefreshed()
        }
        .progressHUD(showing: viewModel.showingHUD)
    }
}
