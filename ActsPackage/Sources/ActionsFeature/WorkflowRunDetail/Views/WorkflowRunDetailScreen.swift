import SwiftUI

struct WorkflowRunDetailScreen: View {
    @ObservedObject var viewModel: WorkflowRunDetailViewModel

    var body: some View {
        List {
            ForEach(viewModel.workflowJobs) { workflowJob in
                VStack(alignment: .leading) {
                    Text(workflowJob.name)
                    ForEach(workflowJob.steps) { step in
                        Text("> " + step.name)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
