import SwiftUI

struct WorkflowRunDetailScreen: View {
    @ObservedObject var viewModel: WorkflowRunDetailViewModel

    var body: some View {
        List {
            ForEach(viewModel.workflowJobs) { workflowJob in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        workflowJob.status.iconImage()
                            .font(.title)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(workflowJob.name)
                                .font(.avenirTitle2.weight(.semibold))

                            Text(workflowJob.formattedJobStatusWithTime)
                                .font(.avenirCaption)
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
