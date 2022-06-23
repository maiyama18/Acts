import GitHubAPI
import SwiftUI

struct WorkflowRunDetailScreen: View {
    @ObservedObject var viewModel: WorkflowRunDetailViewModel

    var body: some View {
        List {
            ForEach(viewModel.workflowJobs) { workflowJob in
                VStack(alignment: .leading) {
                    Text(workflowJob.name)
                        .font(.title2.bold())
                    ForEach(workflowJob.steps) { workflowStep in
                        WorkflowStepView(
                            step: workflowStep,
                            onTap: {
                                await viewModel.onStepTapped(job: workflowJob, step: workflowStep)
                            },
                            onSeeEntireLogTapped: {
                                await viewModel.onSeeEntireLogTapped(job: workflowJob)
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
