import SwiftUI

struct MeetingFooterView: View {
    let speakers: [ScrumTimer.Speaker]
    var skipAction: ()->Void
    
    private var speakerNumber: Int? {
        // guard는 else랑짝인데 조건이 맞아서 else오기 전까진 반복되다가 else에 해당하면 끝남.
        // firstIndex는 조건에 해당하는 첫번째 인덱스를 반환하는 함수, where= if느낌, $0은 현재요소를 의미한다.
        guard let index = speakers.firstIndex(where: { !$0.isCompleted }) else { return nil }
        return index + 1
    }
    private var isLastSpeaker: Bool { // 중요> 마지막페이지에는 버튼이 사라져야 하니깐 .allSatisfy:모두만족시, return 1
        return speakers.dropLast().allSatisfy { $0.isCompleted }
    }
    private var speakerText: String {
        guard let speakerNumber = speakerNumber else { return "No more speakers" }
        return "Speaker \(speakerNumber) of \(speakers.count)"
    }
    var body: some View {
            VStack {
                HStack {
                    if isLastSpeaker {
                        Text("Last Speaker")
                    } else {
                        Text(speakerText)
                        Spacer()
                        Button(action: skipAction) {
                            Image(systemName: "forward.fill")
                        }
                        .accessibilityLabel("Next speaker")
                    }
                }
            }
            .padding([.bottom, .horizontal]) // 패딩 여러개 하고싶어서.
        }
    }

struct MeetingFooterView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingFooterView(speakers: DailyScrum.sampleData[0].attendees.speakers, skipAction: {})
            .previewLayout(.sizeThatFits)
    }
}
