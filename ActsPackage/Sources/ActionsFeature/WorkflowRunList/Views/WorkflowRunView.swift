import GitHub
import SwiftUI

struct WorkflowRunView: View {
    var run: GitHubWorkflowRun

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    run.status.iconImage()
                        .font(.title2)

                    Text(run.title)
                        .font(.body.bold())
                }

                Text(run.headCommitMessage)
                    .font(.caption)
                    .lineLimit(1)

                Text(run.formattedRunStatusWithTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(run.headBranch)
                .font(.caption2.monospaced())
                .foregroundColor(.blue)
                .padding(4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
                .layoutPriority(1)
        }
        .padding(.vertical, 4)
    }
}
