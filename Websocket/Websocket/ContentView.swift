

import Starscream
import SwiftUI


struct ContentView: View {
    @State private var chatMessage = ""
    @StateObject private var viewModel = ViewModel(usingScreamstar: false)
    var body: some View {
        VStack {
            HStack {
                TextField("Enter a message", text: $chatMessage)
                    .padding([.leading, .top, .bottom])
                Button("Send", action: { sendMessageTapped() })
                    .padding(.trailing)
            }

            List(viewModel.messages, id: \.self) { message in
                Text(message)
            }
        }
        .onAppear(perform: viewModel.setupSocket)
        .onDisappear(perform: viewModel.closeSocket)
    }
    
    func sendMessageTapped() {
        viewModel.sendMessageTapped(chatMessage)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
