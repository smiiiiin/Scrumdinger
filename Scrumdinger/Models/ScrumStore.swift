import SwiftUI

@MainActor
class ScrumStore: ObservableObject {
    @Published var scrums: [DailyScrum] = [] //업데이트 된다> @State,@Binding보다 범위가 크고 ObservableObject랑 짝꿍
    
    private static func fileURL() throws -> URL { // URL= return값
        try FileManager.default.url(for: .documentDirectory, // 02. try는 여기 왜 들어와 있어? for,in문법은 뭐고.
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("scrums.data") // ??? 진짜 모르겠다.
    }
    
    func load() async throws { //비동기화는 스타벅스에서 점원이 일을 여러개를 조금조금씩 돌려가면서
        let task = Task<[DailyScrum], Error> { // <>제네릭은 c++의 템플릿같은 것.
            let fileURL = try Self.fileURL() // try? 오류있으면 nil 아니면 그냥
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let dailyScrums = try JSONDecoder().decode([DailyScrum].self, from: data) // 데이터에서 객체형태로 변환.
            return dailyScrums
        }
        let scrums = try await task.value
        self.scrums = scrums
    }
    //얘는 데이터저장이겠지?
    func save(scrums: [DailyScrum]) async throws { //async과 await: 비동기 선언, 호출하기
        let task = Task {
            let data = try JSONEncoder().encode(scrums) //JSON을 이용해서 인코더한 결과
            let outfile = try Self.fileURL() //말그대로 url. 근데 이제 왜 앞에 try가 있는지는 모르겠는.
            try data.write(to: outfile)
        }
        _ = try await task.value // 없던일로 하재
    }
}
