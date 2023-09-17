import UIKit

guard let uploadURL = URL(string: "http://localhost:8080/upload") else {
    fatalError("invalid uploadURL")
}

let jsonData = """
{
  "name": "Networking with URLSession",
  "language": "Swift",
  "version": 5.2
}
""".data(using: .utf8)!
var request = URLRequest(url: uploadURL)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
URLSession.shared.uploadTask(with: request, from: jsonData) { _, response, _ in
    print(response ?? "no response")
}.resume()
