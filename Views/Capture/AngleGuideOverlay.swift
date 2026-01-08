import SwiftUI

struct AngleGuideOverlay: View {
    let angle: PhotoAngle

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)

            // Guide shape - centered and offset up slightly
            guideShape
                .stroke(Color.white, lineWidth: 3)
                .frame(width: guideSize.width, height: guideSize.height)
                .offset(y: -40)

            // Instructions at top
            VStack {
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
                .padding(.top, 100)

                Spacer()
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

    private var guideShape: AnyShape {
        switch angle {
        case .front:
            // Oval for face
            AnyShape(Ellipse())
        case .crown:
            // Circle for top of head
            AnyShape(Circle())
        case .back:
            // Oval for back of head
            AnyShape(Ellipse())
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
