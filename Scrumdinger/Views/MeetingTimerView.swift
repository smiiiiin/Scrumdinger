import SwiftUI

struct MeetingTimerView: View {
    let speakers: [ScrumTimer.Speaker]
    let isRecording: Bool
    let theme: Theme
    
    private var currentSpeaker: String {
        speakers.first(where: { !$0.isCompleted })?.name ?? "Someone"
        // ??=없어??그러면 기본값처리
    }
    
    var body: some View {
        Circle()
            .strokeBorder(Color.gray, lineWidth: 50)
            .overlay {// ZStack()과 유사하나 overlay가 더 디테일한 설정이 있다
                VStack {
                    HeartIcon()
                    Text(currentSpeaker)
                        .font(.title)
                    Text("is speaking")
                    Image(systemName: isRecording ? "mic" : "mic.slash")
                        .font(.title)
                        .padding(.top)
                        .accessibilityLabel(isRecording ? "with transcription" : "without transcription")//
                }
                .accessibilityElement(children: .combine) // 논리적으로 하나로 묶음
                .foregroundStyle(theme.accentColor)
            }
            .overlay  {
                ForEach(speakers) { speaker in
                    //if문 괄호 필요없고 and를 , 로 이어준다
                    if speaker.isCompleted, let index = speakers.firstIndex(where: { $0.id == speaker.id }) {
                        // ???
                        SpeakerArc(speakerIndex: index, totalSpeakers: speakers.count)
                            .rotation(Angle(degrees: -90))
                            .stroke(theme.mainColor, lineWidth: 30)
                    }
                }
            }
            .padding(.horizontal) // 양옆 패딩
    }
}


struct MeetingTimerView_Previews: PreviewProvider {
    static var speakers: [ScrumTimer.Speaker] {
        [ScrumTimer.Speaker(name: "Bill", isCompleted: true), ScrumTimer.Speaker(name: "Cathy", isCompleted: false)]
    }
    
    static var previews: some View {
        MeetingTimerView(speakers: speakers, isRecording: true, theme: .yellow)
    }
}
