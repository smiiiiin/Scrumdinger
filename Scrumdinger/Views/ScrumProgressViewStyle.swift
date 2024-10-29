import SwiftUI

struct ScrumProgressViewStyle: ProgressViewStyle {
    var theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .rotation(Angle(degrees: -90))
                .stroke(theme.accentColor, lineWidth: 12)
                .frame(width: 100, height: 100)
                .padding(.horizontal)
            
            Text("\(Int((configuration.fractionCompleted ?? 0) * 100))%")
                .font(.headline)
                .foregroundColor(theme.accentColor)
        }
    }
}

struct ScrumProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(value: 0.5)
            .progressViewStyle(ScrumProgressViewStyle(theme: .buttercup))
            .previewLayout(.sizeThatFits)
    }
}
