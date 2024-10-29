import Foundation

struct History: Identifiable { // Q. 어디에 쓰이는가?
    let id: UUID
    let date: Date
    var attendees: [DailyScrum.Attendee]
    
    //Date() : 당일날짜
    init(id: UUID = UUID(), date: Date = Date(), attendees: [DailyScrum.Attendee]) {
        self.id = id
        self.date = date
        self.attendees = attendees
    }
}
