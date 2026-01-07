import SwiftUI

struct AngleGuideOverlay: View {
    let angle: PhotoAngle

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)

            // Guide shape
            guideShape
                .stroke(Color.white, lineWidth: 3)
                .frame(width: guideSize.width, height: guideSize.height)

            // Instructions at bottom
            VStack {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: angle.iconName)
                        .font(.title)

                    Text(angle.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(angle.instruction)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .foregroundStyle(.white)
                .padding(.bottom, 120)
            }
        }
    }

    private var guideSize: CGSize {
        switch angle {
        case .front:
            return CGSize(width: 200, height: 280)
        case .crown:
            return CGSize(width: 220, height: 220)
        case .back:
            return CGSize(width: 200, height: 280)
        }
    }

    @ViewBuilder
    private var guideShape: some Shape {
        switch angle {
        case .front:
            // Oval for face
            Ellipse()
        case .crown:
            // Circle for top of head
            Circle()
        case .back:
            // Oval for back of head
            Ellipse()
        }
    }
}

#Preview {
    ZStack {
        Color.gray
        AngleGuideOverlay(angle: .front)
    }
    .ignoresSafeArea()
}
