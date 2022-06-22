import SwiftUI

struct WorkflowRunListView: View {
    @ObservedObject var viewModel: WorkflowRunListViewModel

    var body: some View {
        List {
            ForEach(viewModel.workflowRuns) { workflowRun in
                VStack(alignment: .leading) {
                    Text(workflowRun.name)
                    Text(workflowRun.status)
                    Text(workflowRun.conclusion)
                    Text(workflowRun.createdAt.formatted())
                }
            }
        }
        .listStyle(.plain)
    }
}
