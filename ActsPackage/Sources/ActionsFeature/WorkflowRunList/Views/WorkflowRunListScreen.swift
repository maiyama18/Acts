import SwiftUI

struct WorkflowRunListView: View {
    @ObservedObject var viewModel: WorkflowRunListViewModel

    var body: some View {
        List {
            ForEach(viewModel.workflowRuns) { workflowRun in
                VStack(alignment: .leading) {
                    Text(workflowRun.title)
                    Text(workflowRun.status.formatted())
                    Text(workflowRun.createdAt.formatted())
                }
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
