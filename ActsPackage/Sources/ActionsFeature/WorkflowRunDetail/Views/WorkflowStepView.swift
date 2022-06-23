import GitHubAPI
import SwiftUI

struct WorkflowStepView: View {
    var step: GitHubWorkflowStep
    var onTap: () async -> Void
    var onSeeEntireLogTapped: () async -> Void

    @State private var logHeight: CGFloat = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Group {
                    switch step.log {
                    case .notLoaded:
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    case .loading:
                        ProgressView()
                            .frame(width: 12, height: 12)
                    case .loaded:
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                }
                .frame(width: 16, alignment: .leading)

                step.stepStatus.iconImage()

                Text(step.name)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                Task {
                    await onTap()
                }
            }

            if case let .loaded(log, abbreviated) = step.log {
                VStack(spacing: 0) {
                    if abbreviated {
                        HStack {
                            Text("This log is too long.")

                            Text("See entire log on web")
                                .underline()
                                .onTapGesture {
                                    Task {
                                        await onSeeEntireLogTapped()
                                    }
                                }
                        }
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.orange.opacity(0.2))
                    }

                    ScrollView {
                        Text((abbreviated ? "...\n\n" : "") + log)
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
                }
                .frame(height: logHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}
