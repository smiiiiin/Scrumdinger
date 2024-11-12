import SwiftUI

struct SpeakerArc: Shape {
    let speakerIndex: Int
    let totalSpeakers: Int
    
    // 발화자 당 각도(시간) ex) 4명이면 90도씩
    private var degreesPerSpeaker: Double {
        360.0 / Double(totalSpeakers)
    }
    private var startAngle: Angle {
        Angle(degrees: degreesPerSpeaker * Double(speakerIndex) + 1.0) //약간의 공간을 두려고
    }
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1.0)
    }
    
    func path(in rect: CGRect) -> Path { //?
        let diameter = min(rect.size.width, rect.size.height) - 50.0 // -24.0 잘 바꿨다 ... wow
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}
