import SwiftUI

struct ScrumProgressViewStyle: ProgressViewStyle {
    var theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        ZStack { // 겹쳐 쌓아서 여기 안에서 마지막에 쓴 코드가 제일 위에 오도록
            Circle()
                .trim(from: 0, to: CGFloat(configuration.fractionCompleted ?? 0)) //
                .rotation(Angle(degrees: 270))
                .stroke(Color.red, lineWidth: 100)
                .frame(width: 100, height: 100) // 이게 뭐냐? 좀 작게 하고 싶은데
                .padding(.horizontal)
            
            Text("\(Int((configuration.fractionCompleted ?? 0) * 100))%")
                .font(.headline)
                .foregroundColor(Color.white)
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
