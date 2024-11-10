import SwiftUI

struct HistoryView: View {
    let history: History
    
    var body: some View {
        ScrollView { // 메모에 스크롤 표시 되는 것
            VStack(alignment: .center) {
                Divider().padding(.bottom)
                Text("Attendees")
                    .font(.headline)
                Text(history.attendeeString)
                Divider().padding(.bottom)
                if let transcript = history.transcript {
                    Text("Transcript")
                        .font(.headline)
                    Text(transcript)
                }
            }
        }
        .navigationTitle(Text(history.date, style: .date))
        .padding()
    }
}

extension History {
    var attendeeString: String {
        ListFormatter.localizedString(byJoining: attendees.map { $0.name })
        // point: <ListFormatter.localizedString(byJoining> 한 묶음임. 그냥 외워= 사용자 언어에 맞게 joining(ex.  , || 그리고 || 일본어인 경우 、 )
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var history: History { //프리뷰니깐 넣는 것이다.
        History(attendees: [
            DailyScrum.Attendee(name: "Jon"),
            DailyScrum.Attendee(name: "Darla"),
            DailyScrum.Attendee(name: "Luis")
        ],
                transcript: "this is transcript...blablabla ... haha... ")
    }
    
    static var previews: some View {
        HistoryView(history: history)
    }
}
