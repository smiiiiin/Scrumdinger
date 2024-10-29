import SwiftUI

struct ThemePicker: View {
    @Binding var selection: Theme //selected Theme 값바뀌면 부모뷰에서도 바뀜
    
    var body: some View {
        Picker("select theme", selection: $selection) { // Picker함수 자체에 여백이 있다.
            ForEach(Theme.allCases) { theme in // Theme에서 caseiterable이 있는것.
                ThemeView(theme: theme).tag(theme) //picker-tag 짝이다
            }
        }
        .pickerStyle(.wheel) // 이거 내가 하고싶었던 것!
    }
}

struct ThemePicker_Previews: PreviewProvider {
    static var previews: some View {
        ThemePicker(selection: Binding.constant(.periwinkle))
    }
}

