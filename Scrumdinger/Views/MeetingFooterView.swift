import SwiftUI

struct MeetingFooterView: View {
    let speakers: [ScrumTimer.Speaker]
    var skipAction: ()->Void
    var previousAction: ()->Void
    
    private var speakerNumber: Int? {
        guard let index = speakers.firstIndex(where: { !$0.isCompleted }) else { return nil }
        return index + 1
    }
    //
    private var isFirstSpeaker: Bool {
        return speakers.first?.isCompleted == false
    }
    //마지막사람빼고 모두가 완료되었으면= 그 사람이 마지막 사람
    private var isLastSpeaker: Bool {
        return speakers.dropLast().allSatisfy { $0.isCompleted }
    }
    private var speakerText: String {
        /*guard let speakerNumber = speakerNumber else { return "No more speakers" }*/
        var speakerNumber = speakerNumber ?? 0
        return "Speaker \(speakerNumber) of \(speakers.count)"
    }
    
    var body: some View {
        VStack {
            HStack {
                if isFirstSpeaker {
                    Spacer()
                    Text(speakerText)
                    Spacer()
                    Button(action: skipAction) {
                        Image(systemName: "forward.fill")
                    }
                    .accessibilityLabel("Next speaker")
                }
                else if isLastSpeaker {
                    Button(action: previousAction) {
                        Image(systemName: "backward.fill")
                    }
                    .accessibilityLabel("Next speaker")
                    Spacer()
                    Text("Last Speaker")
                }
                else {
                    Button(action: previousAction) {
                        Image(systemName: "backward.fill")
                    }
                    .accessibilityLabel("Next speaker")
                    Spacer()
                    Text(speakerText)
                    Spacer()
                    Button(action: skipAction) {
                        Image(systemName: "forward.fill")
                    }
                    .accessibilityLabel("Next speaker")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
}

struct MeetingFooterView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingFooterView(speakers: DailyScrum.sampleData[0].attendees.speakers, skipAction: {}, previousAction: {})
            .previewLayout(.sizeThatFits)
    }
}
