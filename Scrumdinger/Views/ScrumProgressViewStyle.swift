import SwiftUI

struct ScrumProgressViewStyle: ProgressViewStyle {
    var theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        ZStack { // 겹쳐 쌓아서 여기 안에서 마지막에 쓴 코드가 제일 위에 오도록
            Circle()
                .trim(from: 0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .rotation(Angle(degrees: 270))
                .stroke(Color.red, lineWidth: 30)
                .frame(width: 30, height: 30)
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
