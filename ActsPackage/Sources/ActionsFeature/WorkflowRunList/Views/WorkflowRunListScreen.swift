import Core
import GitHub
import SwiftUI

struct WorkflowRunListView: View {
    @ObservedObject var viewModel: WorkflowRunListViewModel

    var body: some View {
        Group {
            if !viewModel.showingHUD, viewModel.workflowRuns.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 64))

                    Text(L10n.ActionsFeature.WorkflowRunList.emptyMessage)
                        .font(.avenirTitle2.weight(.semibold))
                }
                .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(viewModel.workflowRuns) { workflowRun in
                        WorkflowRunView(run: workflowRun)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Task {
                                    await viewModel.onWorkflowRunTapped(run: workflowRun)
                                }
                            }
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
