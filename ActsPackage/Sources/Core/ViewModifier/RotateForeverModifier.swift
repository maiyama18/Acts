import SwiftUI

struct RotateForeverModifier: ViewModifier {
    var duration: Double
    @State private var angle: Angle = .degrees(0)

    func body(content: Content) -> some View {
        content
            .rotationEffect(angle)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    angle = .degrees(360)
                }
            }
    }
}
