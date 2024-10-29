import SwiftUI
//almost done!
//enum은 can not inherit struct of swiftui,so it can't use Color

enum Theme: String, CaseIterable, Identifiable { // enum > Theme라는 걸로 묶고 컴퓨터에서 Theme.pi만 쳤을때 nk떠서 오타안나게 할려고
    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow
    
    var accentColor: Color { //글씨
        switch self { /*case 뒤에 색상 목록이 많아서 self를 쓰는거다. 즉, 지금 내가 쓰는 색상설정 기준임. 만약에 case a,b return 1 이렇게 case 뒤에 하나밖에 안오면 self를 붙일 이유가 없다 */
        case Theme.bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow: return Color.black
        case .indigo, .magenta, .navy, .oxblood, .purple: return .white
        }
    }
    var mainColor: Color { //배경
        Color(rawValue) // Color("navy")
    }
    var name: String {
        rawValue.capitalized
    }
    var id: String { // 이름으로 Theme의 id를 구분
        name
    }
}

