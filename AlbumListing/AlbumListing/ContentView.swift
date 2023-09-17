
import SwiftUI

struct ContentView: View {
  
  @ObservedObject var albumQuery = AlbumQuery()
  
  var body: some View {
    NavigationView {
      VStack {
        List(albumQuery.titles, id: \.self) { title in
          Text(title)
        }
      }.navigationBarTitle("Leonard Cohen Albums")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
