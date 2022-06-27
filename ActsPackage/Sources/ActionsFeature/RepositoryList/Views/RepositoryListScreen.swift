import Core
import GitHub
import PKHUD
import SwiftUI

struct RepositoryListScreen: View {
    @ObservedObject var viewModel: RepositoryListViewModel
    @State private var emptyViewHeight: CGFloat = 0

    var body: some View {
        Group {
            if !viewModel.showingHUD, viewModel.usersRepositories.isEmpty, viewModel.favoriteRepositories.isEmpty {
                GeometryReader { proxy in
                    List {
                        VStack(spacing: 16) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 64))

                            Text(L10n.ActionsFeature.RepositoryList.emptyMessage)
                                .font(.avenirTitle2.weight(.semibold))
                        }
                        .frame(height: emptyViewHeight)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .onAppear {
                        emptyViewHeight = proxy.size.height
                    }
                    .refreshable {
                        await viewModel.onPullToRefreshed()
                    }
                }
            } else {
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
            }
        }
        .progressHUD(showing: viewModel.showingHUD)
    }
}
