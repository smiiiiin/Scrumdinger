import Foundation

struct History: Identifiable, Codable { //Codable= 인코딩(객체>JSON) +디코딩(JSON>객체)
    let id: UUID
    let date: Date
    var attendees: [DailyScrum.Attendee]
    var transcript: String? // ?의 의미는 nil일수도 값이 있을수도 있다는 의미 맞지?
     
    //swift는 c++과 달리, Init이 옵션이다
    // transcript: String? = nil
    init(id: UUID = UUID(), date: Date = Date(), attendees: [DailyScrum.Attendee], transcript:String? = nil ) {
        self.id = id
        self.date = date
        self.attendees = attendees
        self.transcript = transcript
    }
}
