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
                    HeartIcon(speakers: speakers)
                    Text(currentSpeaker)
                        .font(.title)
                    Text("is speaking")
                    Image(systemName: isRecording ? "mic" : "mic.slash")
                        .font(.title)
                        .padding(.top)
                        .accessibilityLabel(isRecording ? "with transcription" : "without transcription")// 애플음성인식엔진 에 필요한 라벨링
                }
                .accessibilityElement(children: .combine) // 논리적으로 하나로 묶음
                .foregroundStyle(theme.accentColor)
            }
        
            .overlay {
                ForEach(speakers) { speaker in
                    if let index = speakers.firstIndex(where: { $0.id == speaker.id }) {
                        SpeakerArc(speakerIndex: index, totalSpeakers: speakers.count)
                            .rotation(Angle(degrees: -90))
                            .stroke(
                                speaker.isCompleted ? theme.mainColor : Color.gray,
                                lineWidth: 30
                            )
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

