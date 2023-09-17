import UIKit
let url = URL(string: "https://www.google.com/")!
let request = URLRequest(url: url)

URLSession.shared.dataTask(with: request) { _, response, _ in
    guard let response = response as? HTTPURLResponse,
          let headerFiels = response.allHeaderFields as? [String: String] else { return }
    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFiels, for: url)
    cookies.forEach {
        print($0.name, $0.value, $0.domain)
    }
    HTTPCookieStorage.shared.cookies?.forEach {
        print($0.name, $0.value, $0.domain)
    }
}.resume()
