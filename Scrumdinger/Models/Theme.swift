import SwiftUI

enum Theme: String { // Theme으로 묶으려고 그룹핑하고 스펠링 오타나지 않도록 Theme.navy 이런식으로 할 수 있도록 도와준다.
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
    
    var accentColor: Color { // 글씨체 색상
        switch self {
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow: return .black
        case .indigo, .magenta, .navy, .oxblood, .purple: return .white
        }
    }
    var mainColor: Color {
        Color(rawValue)
    }
    
    var name: String { // 첫글자 대문자 만들기
            rawValue.capitalized // enum사용하다가 Apple 이런식으로 꺼내고 싶을 때.
        }
    
}
