import Foundation

@MainActor // 업데이트는 무조건 메인스레드에서 되야되서 메인스레드로 올려준다
final class ScrumTimer: ObservableObject {
    struct Speaker: Identifiable {
        let name: String
        var isCompleted: Bool
        let id = UUID()
    }
    
    @Published var activeSpeaker = ""
    @Published var secondsElapsed = 0
    @Published var secondsRemaining = 0
    
    /// All meeting attendees, listed in the order they will speak.
    private(set) var speakers: [Speaker] = []
    private(set) var lengthInMinutes: Int
    /// 01. 얘 뭐지? 클로저는 상자같이 일단 마련 그리고 안에 함수로 따로 쓰기 : 유연함을 위해 계속 넣을 수 있어서
    var speakerChangedAction: (() -> Void)?
    
    private weak var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 } // int, float같은. TimeInterval 타입형이다
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerSpeaker: Int {
        (lengthInMinutes * 60) / speakers.count
    }
    // 화자마다 말하는 시간
    // 문제는 버튼과 speakerIndex
    private var secondsElapsedForSpeaker: Int = 0
    private var speakerIndex: Int = 0
    private var speakerText: String {
        return "Speaker \(speakerIndex + 1): " + speakers[speakerIndex].name
    }
    private var startDate: Date?
    
    init(lengthInMinutes: Int = 0, attendees: [DailyScrum.Attendee] = []) {
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.speakers
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
    
    // Start the timer.
    func startScrum() {
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            self?.update()
        }
        timer?.tolerance = 0.1
        changeToSpeaker(at: 0)
    }
    
    /// Stop the timer.
    func stopScrum() {
        timer?.invalidate()
        timerStopped = true
    }
    func skipSpeaker() {
        guard speakerIndex >= 0 && speakerIndex < speakers.count else { return }
        speakers[speakerIndex].isCompleted = true
        changeToSpeaker(at: speakerIndex + 1)
    }

    /// Go back to the previous speaker.
    func previousSpeaker() {
        guard speakerIndex > 0 else { return }
        // 현재 스피커 상태를 미완료로 설정
        speakers[speakerIndex].isCompleted = false
        changeToSpeaker(at: speakerIndex - 1)
    }
    
    @MainActor
    private func changeToSpeaker(at index: Int) {
        // Index가 유효한 범위 내에 있는지 확인
        guard index >= 0 && index < speakers.count else { return }
        
        speakerIndex = index
        activeSpeaker = speakerText
        secondsElapsedForSpeaker = 0
        
        // Index 0일 때 이전 스피커 상태 초기화
        if index == 0 {
            for i in speakers.indices {
                speakers[i].isCompleted = false
                print("this is i: \(i) ")
            }
        }
        
        // 타이머 업데이트
        secondsElapsed = index * secondsPerSpeaker
        secondsRemaining = lengthInSeconds - secondsElapsed
        startDate = Date()
    }
    
    nonisolated private func update() {
        
        Task { @MainActor in
            guard let startDate,
                  !timerStopped else { return }
            let secondsElapsed = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
            secondsElapsedForSpeaker = secondsElapsed
            self.secondsElapsed = secondsPerSpeaker * speakerIndex + secondsElapsedForSpeaker
            guard secondsElapsed <= secondsPerSpeaker else {
                return
            }
            secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)
            
            if secondsElapsedForSpeaker >= secondsPerSpeaker {
                changeToSpeaker(at: speakerIndex + 1)
                speakerChangedAction?()
            }
        }
    }
    
    
    func reset(lengthInMinutes: Int, attendees: [DailyScrum.Attendee]) {
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.speakers
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
}


extension Array<DailyScrum.Attendee> {
    var speakers: [ScrumTimer.Speaker] {
        if isEmpty {
            return [ScrumTimer.Speaker(name: "Speaker 1", isCompleted: false)]
        } else {
            return map { ScrumTimer.Speaker(name: $0.name, isCompleted: false) }
        }
    }
}
