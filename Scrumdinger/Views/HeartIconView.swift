import SwiftUI

struct HeartIcon: View {
    
    let speakers: [ScrumTimer.Speaker]
    
    private var currentSpeaker: String {
        speakers.first(where: { !$0.isCompleted })?.name ?? "Someone"
        // ??=없어??그러면 기본값처리
    }
    
    var body: some View{
        Image(systemName: "heart.fill")
            .font(.system(size: 40))
            .foregroundColor(Color.white)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red, Color.green, Color.blue]),
                            startPoint: .top,
                            endPoint: .bottomTrailing)
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue, radius: 10, x: 0, y: 10)
                    .overlay(
                        Circle()
                            .fill(Color.red)
                            .frame(width: 35, height: 35)
                            .overlay(
                                Text(currentSpeaker)
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                            )
                            .shadow(color: .red, radius: 10, x: 5, y: 5)
                        , alignment: .topLeading
                    )
            )
    }
}
struct Overlay_Previews: PreviewProvider {
    static var speakers: [ScrumTimer.Speaker] {
        [ScrumTimer.Speaker(name: "Bill", isCompleted: true), ScrumTimer.Speaker(name: "Cathy", isCompleted: false)]
    }
    
    static var previews: some View {
        HeartIcon(speakers: speakers)
    }
}
