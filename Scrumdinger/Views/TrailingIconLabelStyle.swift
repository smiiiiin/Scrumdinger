import SwiftUI

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View { // makeBody(configuration: 이 함수는 내장된 것
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle { // trailingIcon일 때만 이 경우를 적용한다
    static var trailingIcon: Self { Self() } 
}

struct TrailingIconLabelStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Label("Sample Text", systemImage: "star.fill")
                .labelStyle(.trailingIcon) // TrailingIconLabelStyle 적용
                .padding()

            Label("Another Example", systemImage: "heart.fill")
                .labelStyle(.trailingIcon) // 또 다른 라벨 예시
                .padding()
        }
        .previewLayout(.sizeThatFits) // 프리뷰 크기 설정
    }
}
