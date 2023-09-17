import Vapor

struct VideoCourse: Content {
  let name: String
  let language: String
  let version: Double
}

func routes(_ app: Application) throws {
    app.get { _ async in
        "It works!"
    }
    
    app.get("hello") { _ async -> String in
        "Hello, world!"
    }
    
    app.webSocket("chat") { _, ws in
        ws.send("Connected")
        ws.onText { ws, text in
            ws.send("Text received: \(text)")
            print("received from client: \(text)")
        }

        ws.onClose.whenComplete { result in
            switch result {
            case .success():
                print("Closed")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    app.post("upload") { request -> HTTPResponseStatus in
        let course = try request.content.decode(VideoCourse.self)
        print("course name: ", course.name)
        print("language: ", course.language)
        print("version: ", course.version)
        return .ok
    }
}
