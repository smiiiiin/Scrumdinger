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
    
    private var audioEngine: AVAudioEngine? //input
    private var request: SFSpeechAudioBufferRecognitionRequest? // 버퍼를 받아서 애플음성인식엔진에 보냄!
    private let recognizer: SFSpeechRecognizer? // 애플음성엔진 like Chapgpt:그래서 얜 let이다. 변할 필요가 없어.
    private var task: SFSpeechRecognitionTask? // 상태관리 작업관리자
    
    
    init() {
        recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer) //
            return //아무것도 return 안해?
        }
        
        Task {
            do {
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
        // 01. 근데 왜 이 앱에서 소리입력만 우선순위를 중시하는걸까?
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
    //
    private func transcribe() {
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable) //자기복제야?
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
            })
        } catch {
            self.reset()
            self.transcribe(error)
        }
    }
    
    /// Reset the speech recognizer.
    private func reset() { //왜 private인지
        task?.cancel() // 뭘 취소
        audioEngine?.stop() // input.을 멈춰
        audioEngine = nil //input을 nil로 초기화
        request = nil //이거 뭐야
        task = nil //이거뭐야 왜 nil로 초기화
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
