import AsyncAlgorithms
import Combine
import Core
import GitHub
import GitHubAPI
import SwiftUI

@MainActor
public final class RepositoryListViewModel: ObservableObject {
    enum Event {
        case showSettings
        case showRepository(repository: GitHubRepository)
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var favoriteRepositories: [GitHubRepository] = []
    @Published private(set) var usersRepositories: [GitHubRepository] = []
    @Published private(set) var showingHUD: Bool = false
    @Published private(set) var loadingMore: Bool = false
    @Published private(set) var hasMoreUsersRepositories: Bool = false
    @Published private(set) var usersRepositoriesPage: Int = 0

    let events: AsyncChannel<Event> = .init()

    private let gitHubUseCase: GitHubUseCaseProtocol
    private let cacheClient: CacheClientProtocol

    public init(gitHubUseCase: GitHubUseCaseProtocol, cacheClient: CacheClientProtocol) {
        self.gitHubUseCase = gitHubUseCase
        self.cacheClient = cacheClient
    }

    func onViewLoaded() async {
        showingHUD = true
        defer {
            showingHUD = false
        }
        do {
            usersRepositoriesPage = 1
            let repositories = try await gitHubUseCase.getRepositories(page: usersRepositoriesPage)
            favoriteRepositories = repositories.favoriteRepositories
            usersRepositories = repositories.usersRepositories
            hasMoreUsersRepositories = repositories.hasMoreUsersRepositories
        } catch {
            await handleGitHubError(error: error)
        }

        cacheClient.deletePreviousDaysGitHubWorkflowStepLogObjects()
    }

    func onPullToRefreshed() async {
        do {
            usersRepositoriesPage = 1
            let repositories = try await gitHubUseCase.getRepositories(page: usersRepositoriesPage)
            favoriteRepositories = repositories.favoriteRepositories
            usersRepositories = repositories.usersRepositories
            hasMoreUsersRepositories = repositories.hasMoreUsersRepositories
        } catch {
            await handleGitHubError(error: error)
        }
    }

    func onLoadMoreUsersRepositoriesTapped() async {
        loadingMore = true
        defer {
            loadingMore = false
        }
        do {
            usersRepositoriesPage += 1
            let repositories = try await gitHubUseCase.getRepositories(page: usersRepositoriesPage)
            usersRepositories += repositories.usersRepositories
            hasMoreUsersRepositories = repositories.hasMoreUsersRepositories
        } catch {
            await handleGitHubError(error: error)
        }
    }

    func onRepositoryTapped(repository: GitHubRepository) async {
        await events.send(.showRepository(repository: repository))
    }

    func onSettingsButtonTapped() async {
        await events.send(.showSettings)
    }

    func onFavorited(repository: GitHubRepository) async {
        do {
            try cacheClient.saveFavoriteGitHubRepository(object: repository.toObject())
            withAnimation {
                favoriteRepositories.append(repository)
                usersRepositories.removeAll(where: { $0.id == repository.id })
            }
        } catch {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }

    func onUnFavorited(repository: GitHubRepository) async {
        do {
            try cacheClient.deleteFavoriteGitHubRepository(id: repository.id)
            withAnimation {
                favoriteRepositories.removeAll(where: { $0.id == repository.id })
                usersRepositories.insert(repository, at: 0)
            }
        } catch {
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }

    private func handleGitHubError(error: Error) async {
        switch error {
        case GitHubAPIError.unauthorized:
            await events.send(.unauthorized)
        case GitHubAPIError.disconnected:
            await events.send(.showError(message: L10n.ErrorMessage.disconnected))
        default:
            await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
        }
    }
}
