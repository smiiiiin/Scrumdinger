import Foundation
import AVFoundation

extension AVPlayer { //extension : 내장class여서 수정불가능하고 추가해야한다.
    static let sharedDingPlayer: AVPlayer = {
        //guard 쓰는 이유: 초기에 url이 있는 것임을 보장하고 없으면 삭제한다
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        print(url)
        return AVPlayer(url: url)
    }()
}
