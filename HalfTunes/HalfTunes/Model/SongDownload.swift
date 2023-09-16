

import SwiftUI

class SongDownload: NSObject, ObservableObject {
    var downloadTask: URLSessionDownloadTask?
    var downloadURL: URL?
    var resumeData: Data?
    @Published var downloadLocation: URL?
    @Published var downloadedAmount: Float = 0
    @Published var state: DownloadState = .waiting
    enum DownloadState {
        case waiting
        case downloading
        case paused
        case finished
    }

    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    func fetchSongAtUrl(_ item: URL) {
        downloadURL = item
        downloadTask = urlSession.downloadTask(with: item)
        downloadTask?.resume()
        state = .downloading
    }
    
    func cancel() {
        downloadTask?.cancel()
        DispatchQueue.main.async {
            self.state = .waiting
            self.downloadedAmount = 0
        }
    }
    
    func pause() {
        downloadTask?.cancel(byProducingResumeData: { data in
            DispatchQueue.main.async {
                self.resumeData = data
                self.state = .paused
            }
        })
    }
    
    func resume() {
        guard let resumeData else { return }
        downloadTask = urlSession.downloadTask(withResumeData: resumeData)
        downloadTask?.resume()
        state = .downloading
    }
}

extension SongDownload: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.downloadedAmount = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let lastPathComponent = downloadURL?.lastPathComponent
        else {
            fatalError()
        }

        let destinationUrl = documentsPath.appendingPathComponent(lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
            }
            try fileManager.copyItem(at: location, to: destinationUrl)
            DispatchQueue.main.async {
                self.downloadLocation = destinationUrl
                self.state = .finished
            }
        } catch {
            print(error)
        }
    }
}
