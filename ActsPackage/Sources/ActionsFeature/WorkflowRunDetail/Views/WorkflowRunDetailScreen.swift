import SwiftUI

struct WorkflowRunDetailScreen: View {
    @ObservedObject var viewModel: WorkflowRunDetailViewModel

    var body: some View {
        List {
            ForEach(viewModel.workflowJobs) { workflowJob in
                VStack(alignment: .leading) {
                    HStack {
                        workflowJob.status.iconImage()
                            .font(.title)

                        VStack(alignment: .leading) {
                            Text(workflowJob.name)
                                .font(.title2.bold())
                                .bold()

                            Text(workflowJob.formattedJobStatusWithTime)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(workflowJob.formattedDuration)
                            .font(.callout.monospaced().bold())
                    }

                    ForEach(workflowJob.steps) { workflowStep in
                        WorkflowStepView(
                            step: workflowStep,
                            onTap: {
                                await viewModel.onStepTapped(step: workflowStep)
                            },
                            onSeeEntireLogTapped: {
                                await viewModel.onSeeEntireLogTapped(job: workflowJob)
                            }
                        )
                    }
                }
            }
        }
        .refreshable {
            await viewModel.onPullToRefreshed()
        }
        .listStyle(.plain)
    }
}
