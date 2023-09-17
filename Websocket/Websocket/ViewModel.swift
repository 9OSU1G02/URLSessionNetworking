//
//  ViewModel.swift
//  Websocket
//
//  Created by 9OSU1G02 on 9/17/23.

import Starscream
import UIKit

class ViewModel: NSObject, ObservableObject {
    @Published var messages: [String] = []
    @Published var isConnected = false
    private var webSocketTask: URLSessionWebSocketTask!
    var screamstarSocket: WebSocket!
    var usingScreamstar: Bool

    init(usingScreamstar: Bool) {
        self.usingScreamstar = usingScreamstar
    }

    func setupSocket() {
        if usingScreamstar {
            var request = URLRequest(url: URL(string: "ws://localhost:8080/chat")!)
            request.timeoutInterval = 5
            screamstarSocket = WebSocket(request: request)
            screamstarSocket.delegate = self
            screamstarSocket.connect()
        } else {
            let websocketURL = URL(string: "ws://localhost:8080/chat")!
            webSocketTask = URLSession.shared.webSocketTask(with: websocketURL)
            webSocketTask.delegate = self
            listenForMessages()
            webSocketTask.resume()
        }
    }

    func listenForMessages() {
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self.messages.insert(text, at: 0)
                    }
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    print("unknow")
                }
                self.listenForMessages()
            case .failure(let failure):
                print("Failed to receive message: ", failure.localizedDescription)
            }
        }
    }

    func closeSocket() {
        if usingScreamstar {
            screamstarSocket.disconnect()
        } else {
            webSocketTask.cancel(with: .goingAway, reason: nil)
        }
    }

    func sendMessageTapped(_ chatMessage: String) {
        let message = URLSessionWebSocketTask.Message.string(chatMessage)
        if usingScreamstar {
            screamstarSocket.write(string: chatMessage)
        } else { webSocketTask.send(message) { error in
            if let error {
                print(error.localizedDescription)
            }
        }
        }
    }
}

extension ViewModel: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let text):
            messages.insert(text, at: 0)
            print("Received text: \(text)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        case .peerClosed:
            break
        }
    }

    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}

extension ViewModel: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("socket did open")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("socket did close")
    }
}
