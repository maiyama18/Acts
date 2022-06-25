import GitHub
import SwiftUI

struct RepositoryView: View {
    var repository: GitHubRepository
    var favorited: Bool
    var onTapped: () -> Void
    var onFavoriteButtonTapped: () -> Void

    var body: some View {
        HStack {
            HStack {
                AsyncImage(url: URL(string: repository.owner.avatarUrl)) { image in
                    image
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                } placeholder: {
                    Color.gray.opacity(0.1)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading) {
                    Text(repository.owner.login)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(repository.name)
                        .font(.callout.bold())
                }

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTapped()
            }

            Button(action: {
                onFavoriteButtonTapped()
            }) {
                Image(systemName: "heart")
                    .font(.body)
                    .symbolVariant(favorited ? .fill : .none)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
            }
        }
    }
}
