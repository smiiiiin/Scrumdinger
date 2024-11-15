import SwiftUI

struct MeetingVieww: View {
    let speakers: [ScrumTimer.Speaker]
    let isRecording: Bool
    let theme: Theme
    
    // 현재 스피커 인덱스를 추적하기 위한 상태 변수
    @State private var currentSpeakerIndex: Int = 0
    
    private var currentSpeaker: String {
        // 현재 스피커의 이름을 반환
        speakers.indices.contains(currentSpeakerIndex) ? speakers[currentSpeakerIndex].name : "Someone"
    }
    
    var body: some View {
        VStack {
            // 타이머 표시
            Circle()
                .strokeBorder(Color.gray, lineWidth: 50)
                .overlay {
                    VStack {
                        HeartIcon(speakers: speakers)
                        Text(currentSpeaker)
                            .font(.title)
                        //index는 0~3이다.
                        Text("\(currentSpeakerIndex+1)st person\nis speaking")
                        Image(systemName: isRecording ? "mic" : "mic.slash")
                            .font(.title)
                            .padding(.top)
                            .accessibilityLabel(isRecording ? "with transcription" : "without transcription")
                    }
                    .accessibilityElement(children: .combine)
                    .foregroundStyle(theme.accentColor)
                }
                .overlay {
                    ForEach(speakers.indices, id: \.self) { index in
                        if speakers[index].isCompleted {
                            SpeakerArc(speakerIndex: index, totalSpeakers: speakers.count)
                                .rotation(Angle(degrees: index == currentSpeakerIndex ? -90 : 90)) // 회전 처리
                                .stroke(theme.mainColor, lineWidth: 30)
                        }
                    }
                }
                .padding(.horizontal)
            
            // 이전 버튼 추가
            HStack {
                Button(action: {
                    moveToPreviousSpeaker()
                }) {
                    Text("Previous")
                        .padding()
                        .background(Capsule().fill(Color.blue))
                        .foregroundColor(.white)
                }
                .disabled(currentSpeakerIndex <= 0) // 첫 번째 스피커에서는 비활성화
                
                Button(action: {
                    moveToNextSpeaker()
                }) {
                    Text("Next")
                        .padding()
                        .background(Capsule().fill(Color.green))
                        .foregroundColor(.white)
                }
                .disabled(currentSpeakerIndex >= speakers.count - 1) // 마지막 스피커에서는 비활성화
            }
        }
    }
    
    // 이전 스피커로 이동하는 함수
    private func moveToPreviousSpeaker() {
        guard currentSpeakerIndex > 0 else { return }
        currentSpeakerIndex -= 1
    }
    
    // 다음 스피커로 이동하는 함수
    private func moveToNextSpeaker() {
        guard currentSpeakerIndex < speakers.count - 1 else { return }
        currentSpeakerIndex += 1
    }
}

struct MeetingVieww_Previews: PreviewProvider {
    static var speakers: [ScrumTimer.Speaker] {
        [ScrumTimer.Speaker(name: "Bill", isCompleted: true), ScrumTimer.Speaker(name: "Cathy", isCompleted: false),
         ScrumTimer.Speaker(name: "jisoo", isCompleted: false),
         ScrumTimer.Speaker(name: "jenny", isCompleted: false)
        ]
    }
    
    static var previews: some View {
        MeetingVieww(speakers: speakers, isRecording: true, theme: .yellow)
    }
}
