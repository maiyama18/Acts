import GitHub
import SwiftUI

struct WorkflowRunListView: View {
    @ObservedObject var viewModel: WorkflowRunListViewModel

    var body: some View {
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
    }
}
