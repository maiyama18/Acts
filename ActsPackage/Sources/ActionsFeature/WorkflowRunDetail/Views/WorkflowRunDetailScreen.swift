import Core
import SwiftUI

struct WorkflowRunDetailScreen: View {
    @ObservedObject var viewModel: WorkflowRunDetailViewModel

    var body: some View {
        Group {
            if !viewModel.showingHUD, viewModel.workflowJobs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 64))

                    Text(L10n.ActionsFeature.WorkflowRunDetail.emptyMessage)
                        .font(.avenirTitle2.weight(.semibold))

                    Text(L10n.ActionsFeature.WorkflowRunDetail.emptyLinkText)
                        .font(.avenirBody)
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            Task {
                                await viewModel.onOpenWorkflowRunOnBrowserTapped()
                            }
                        }
                }
                .foregroundStyle(.secondary)
            } else {
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
        .progressHUD(showing: viewModel.showingHUD)
    }
}
