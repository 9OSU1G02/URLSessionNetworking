

import SwiftUI

struct ContentView: View {
    @State private var musicItems: [MusicItem] = []

    var body: some View {
        VStack {
            Button(action: fetchMusic) {
                Text("Fetch Music")
            }
            List(musicItems) { item in
                Text(item.trackName)
            }
            Spacer()
        }
    }

    func fetchMusic() {
        guard let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=cohen") else {
            return
        }
        URLSession(configuration: .default).dataTask(with: .init(url: url)) { data, response, _ in
            let decoder = JSONDecoder()
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode),
                  let data,
                  let response = try? decoder.decode(MediaResponse.self, from: data) else {
                return
            }
            DispatchQueue.main.async {
                self.musicItems = response.results
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
