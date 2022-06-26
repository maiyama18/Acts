import Core
import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section(content: {
                HStack {
                    Text(L10n.SettingsFeature.versionKey)
                        .font(.avenirCallout)

                    Spacer()

                    Text(viewModel.versionString)
                        .foregroundColor(.gray)
                        .font(.subheadline.monospaced())
                }
            }, header: {
                Text(L10n.SettingsFeature.aboutApp)
                    .font(.avenirCaption.weight(.semibold))
            })

            Section(content: {
                Button(action: {
                    Task {
                        await viewModel.onSignOutButtonTapped()
                    }
                }) {
                    Text(L10n.SettingsFeature.signOutFromGithub)
                        .font(.avenirCallout.weight(.semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }, header: {
                Text("")
            })
        }
        .listStyle(.insetGrouped)
    }
}
