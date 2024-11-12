import SwiftUI

struct HeartIcon: View {
    
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
                                Text("2")
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
    static var previews: some View {
        HeartIcon()
    }
}
