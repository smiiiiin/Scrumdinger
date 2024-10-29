import SwiftUI

struct ScrumsView: View {
    @Binding var scrums: [DailyScrum] // binding 업데이트 되는 정보가 다른 뷰에도 적용되게 하려고
    @State private var isPresentingNewScrumView = false // state: 같은 뷰 내에서 업데이트

    var body: some View {
        NavigationStack { //모든 리스트가 뒤로가기 버튼 제공 
            List($scrums) { $scrum in
                NavigationLink(destination: DetailView(scrum: $scrum)) {
                    CardView(scrum: scrum)
                }
                .listRowBackground(scrum.theme.mainColor)
            }
            .navigationTitle("Daily Scrums")
            .toolbar {
                Button(action: {
                    isPresentingNewScrumView = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Scrum")
            }
        }
        .sheet(isPresented: $isPresentingNewScrumView) { //추가될것 아니면 이거 왜 쓴거지?
            NewScrumSheet(scrums: $scrums, isPresentingNewScrumView: $isPresentingNewScrumView)
        }
    }
}


struct ScrumsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrumsView(scrums: .constant(DailyScrum.sampleData))
    }
}
