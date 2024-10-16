import SwiftUI

@main // 애트리뷰트: 여기가 시작이야~ 알려주는 것
struct ScrumdingerApp: App { //앱이름: 앱
    var body: some Scene { // 전체화면 구성하는 것;scene
        WindowGroup {
            ScrumsView(scrums: DailyScrum.sampleData)
        }
    }
}
