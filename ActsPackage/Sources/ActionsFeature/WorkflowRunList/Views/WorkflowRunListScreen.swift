import SwiftUI

struct WorkflowRunListView: View {
    @ObservedObject var viewModel: WorkflowRunListViewModel

    var body: some View {
        List {
            ForEach(viewModel.workflowRuns) { workflowRun in
                VStack(alignment: .leading) {
                    Text(workflowRun.name)
                    Text(workflowRun.runStatus.formatted())
                    Text(workflowRun.createdAt.formatted())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        await viewModel.onWorkflowRunTapped(workflowRun: workflowRun)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
