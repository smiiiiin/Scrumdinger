import SwiftUI

struct ThemeView: View {
    let theme: Theme
    var body: some View { // var body: some View
        Text(theme.id) //()or:이 =이 된다
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(theme.mainColor)
            .foregroundColor(theme.accentColor)
            //.clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView(theme: .indigo)
    }
}
