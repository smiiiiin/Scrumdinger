import Foundation
import AVFoundation
import Speech // SFSpeechRecognizer 프레임워크
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
actor SpeechRecognizer: ObservableObject { //왜 actor: 직렬화해서 동기화문제가 발생하지 않는다.
    //ObservableObject : ui와 객체의 연결. 객체를 볼 수 있다?
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self { //현재 상태를 확인
            case .nilRecognizer: return "Can't initialize speech recognizer" // 소리파일 없음
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech" // 권한 없음
            case .notPermittedToRecord: return "Not permitted to record audio" // 녹음할 수 없음
            case .recognizerIsUnavailable: return "Recognizer is unavailable" // 애플음성엔진이용불가능
            }
        }
    }
    
    @MainActor var transcript: String = "" // @MainActor = 메인 스레드에서 작동.
    // 스피치리코그나이저(=애플음성인식엔진)페이지에서 가장 중요한 것.
    private var audioEngine: AVAudioEngine? //input
    private var request: SFSpeechAudioBufferRecognitionRequest? // 버퍼를 받아서 애플음성인식엔진에 보냄!
    private let recognizer: SFSpeechRecognizer? // 애플음성엔진 like Chapgpt:그래서 얜 let이다. 변할 필요가 없어.
    private var task: SFSpeechRecognitionTask? // 상태관리 작업관리자
    
    
    init() {
        recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer)
            return
        }
        
        Task {
            do {
                //조건이 해당되길 보장(바라면서)하면서 조건불만족시, else구문 돌려돌려돌림판~
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                transcribe(error)
            }
        }
    }
    
    @MainActor func startTranscribing() {
        // ?. 근데 왜 이 앱에서 소리입력만 우선순위를 중시하는걸까?
        Task { //우선순위 명시되지 않으면 auto모드
            await transcribe() // 비동기화여서 동시에 다른작업을 할 수 있다. 동기화문제(하나의 작업을 하는 동안 화면전환이 불가능함)
        }
    }
    
    @MainActor func resetTranscript() {
        Task {
            await reset()
        }
    }
    
    @MainActor func stopTranscribing() {
        Task {
            await reset()
        }
    }
    
    //? 이거 그냥 존나 어렵다.
    private func transcribe() {
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine() //input관리
            self.audioEngine = audioEngine //apple검색엔진
            self.request = request // 데이터버퍼 엔진에 요청
            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error) //관리자
            })
        } catch {
            self.reset()
            self.transcribe(error)
        }
    }
    
    /// Reset the speech recognizer.
    private func reset() { // apple검색엔진인 recognizer빼고 다 nil처리
        task?.cancel() // 상태관리자.취소 + 객체의 작업을 중지 메모리는 해제 하지 않는다
        audioEngine?.stop() // input.을 멈춰
        audioEngine = nil //input을 nil로 초기화
        request = nil // 검색엔진으로 데이터버퍼보내는 것 비우기
        task = nil // 상태관리자 비우기 + 객체 메모리까지 해제(=nil)
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    nonisolated private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            transcribe(result.bestTranscription.formattedString)
        }
    }
    
    // 여기부터 잠시 넘기자. 어렵다
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
    nonisolated private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
        }
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
