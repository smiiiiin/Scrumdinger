import Foundation

@MainActor
final class ScrumTimer: ObservableObject {
    /// A struct to keep track of meeting attendees during a meeting.
    struct Speaker: Identifiable {
        /// The attendee name.
        let name: String
        /// True if the attendee has completed their turn to speak.
        var isCompleted: Bool
        /// Id for Identifiable conformance.
        let id = UUID()
    }
    
    /// The name of the meeting attendee who is speaking.
    @Published var activeSpeaker = ""
    /// The number of seconds since the beginning of the meeting.
    @Published var secondsElapsed = 0
    /// The number of seconds until all attendees have had a turn to speak.
    @Published var secondsRemaining = 0
    /// All meeting attendees, listed in the order they will speak.
    ///
    private(set) var speakers: [Speaker] = []
    
    /// The scrum meeting length.
    private(set) var lengthInMinutes: Int
    /// A closure that is executed when a new attendee begins speaking.
    var speakerChangedAction: (() -> Void)?
    
    private weak var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerSpeaker: Int {
        (lengthInMinutes * 60) / speakers.count
    }
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
    
    /// Advance the timer to the next speaker.
    func skipSpeaker() {
        guard speakerIndex >= 0 && speakerIndex < speakers.count else { return }
        speakers[speakerIndex].isCompleted = true
        changeToSpeaker(at: speakerIndex + 1)
    }
    
    /// Go back to the previous speaker.
    func previousSpeaker() {
        guard speakerIndex > 0 else { return }
        // 이전 스피커로 이동!!
        speakers[speakerIndex].isCompleted = false
        changeToSpeaker(at: speakerIndex - 1)
    }
    
    //changeToSpeaker(at: 2 - 1 =0 ) 3번째(idx2)에서 2(idx1)번째로 돌리기
    
    @MainActor
    private func changeToSpeaker(at index: Int) {
        // Index가 유효한 범위 내에 있는지 확인
        guard index >= 0 && index < speakers.count else { return }
        
        // Index 0일 때 이전 스피커 상태 초기화
        if index == 0 {
            for i in speakers.indices {
                speakers[i].isCompleted = false
                print("this is i: \(i) ")
            }
        }
        // 현재 스피커 설정 및 상태 업데이트
        speakerIndex = index
        activeSpeaker = speakerText
        secondsElapsedForSpeaker = 0
        
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
