import GitHubAPI
import SwiftUI

struct WorkflowStepView: View {
    var step: GitHubWorkflowStep
    var onTap: () async -> Void

    @State private var logHeight: CGFloat = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: step.hasLog ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12))
                    .frame(width: 18, alignment: .leading)

                Text(step.name)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                Task {
                    await onTap()
                }
            }

            if let log = step.log {
                ScrollView {
                    Text(log)
                        .font(.caption.monospaced())
                        .lineSpacing(4)
                        .padding(8)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        let height = proxy.size.height
                                        if height < logHeight {
                                            logHeight = height
                                        }
                                    }
                            }
                        )
                }
                .frame(height: logHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}
