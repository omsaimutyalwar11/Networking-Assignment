//
//  BackgroundDownloader.swift
//  Postboard
//
//  TASK 5 - a download that keeps going after you leave the app.
//
//  Most of this file is written for you: the file-saving method and three of
//  the four delegate callbacks. Read them, because you will be asked about
//  them at review.
//
//  You write four things, each marked TODO. Three are here:
//    - the session itself, in init()
//    - startDownload()
//    - urlSessionDidFinishEvents(forBackgroundURLSession:)
//
//  The fourth is in AppDelegate.swift: handleEventsForBackgroundURLSession.
//  Those two work as a pair, so read both before you write either.
//

import Foundation

final class BackgroundDownloader: NSObject {

    static let shared = BackgroundDownloader()

    /// Must be the same on every launch. It is how the system hands a
    /// relaunched app back the transfers it had running.
    private static let identifier = "com.training.Postboard.background"

    /// 100 MB on purpose. A small file finishes before you can background the
    /// app, so you would never see the behaviour you are building.
    private static let fileURL = URL(string: "https://proof.ovh.net/files/100Mb.dat")!

    /// Where the finished file should be saved.
    static let savedFileName = "large.dat"

    /// The app delegate puts the system's completion handler here.
    var backgroundCompletionHandler: (() -> Void)?

    /// Call on the main thread, 0 to 1.
    var onProgress: ((Double) -> Void)?

    /// Call on the main thread when the transfer ends.
    var onFinish: ((String) -> Void)?

    /// Created once, in init(), and never torn down.
    ///
    /// It cannot be a `let` because the session needs `self` as its delegate,
    /// and `self` does not exist until super.init() has run. That is also why
    /// it is built in init() rather than up here.
    private var session: URLSession!

    private override init() {
        super.init()

        // Created the URLSessionConfiguration using background session with the unique identifier.
        let configuration = URLSessionConfiguration.background(withIdentifier: Self.identifier)

        // Setting the isDiscretionary, sessionSendsLaunchEvents properties in configuration.
        /*
         isDiscretionary = false:
         The system tries to start and continue the download as soon as possible without waiting for ideal conditions like Wi-Fi or charging.

         isDiscretionary = true:
         The system can delay the download and choose a better time to run it, based on conditions such as network availability or charging.

         sessionSendsLaunchEvents = true:
         Allows iOS to launch the app in the background when there are events to deliver from the background URLSession, such as when a download finishes.

         sessionSendsLaunchEvents = false:
         iOS does not launch the app in the background just to deliver events from the background URLSession.
         */
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = true

        // Created a URLSession and assigned it to the session property.
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        // Printing the EventLog.
        EventLog.shared.log("Entered into the init of BackgroundDownloader class.")
    }

    /// Starts the download.
    ///
    /// TRAP: set `taskDescription` on the task to Self.savedFileName before you
    /// resume it. Why not just store the name in a property on this class?
    /// Because when the system relaunches your app this object is brand new
    /// and any property you set is gone, whereas taskDescription is stored
    /// with the task by the system and handed back to you.
    ///
    /// Steps: make a download task for Self.fileURL, set taskDescription,
    /// resume it, and log that you did.
    func startDownload() {
        // Created a download task.
        let task = session.downloadTask(with: Self.fileURL)

        // Set the Self.savedFileName to the taskDescription.
        task.taskDescription = Self.savedFileName
        task.resume()
        EventLog.shared.log("startDownload is running.")
    }

    /// GIVEN - moves the finished file out of its temporary location into
    /// Documents. Called for you from didFinishDownloadingTo below.
    ///
    /// Worth understanding even though it is written for you: the temporary
    /// file is deleted the moment didFinishDownloadingTo returns. That is why
    /// this is an ordinary synchronous method. Wrapping this work in a
    /// DispatchQueue.async or a Task would let didFinishDownloadingTo return
    /// first, and the file would be gone before the move ran.
    func save(_ temporaryURL: URL, as name: String) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destination = documents.appendingPathComponent(name)

        do {
            try? FileManager.default.removeItem(at: destination)
            try FileManager.default.moveItem(at: temporaryURL, to: destination)

            let bytes = (try? destination.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            EventLog.shared.log("saved \(name) - \(bytes) bytes")
        } catch {
            EventLog.shared.log("could not save: \(error.localizedDescription)")
        }
    }
}

// MARK: - Delegate callbacks (the first three are GIVEN; the last is yours)

extension BackgroundDownloader: URLSessionDownloadDelegate {

    /// The download finished and the file is sitting at `location`, but only
    /// until this method returns.
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {

        EventLog.shared.log("didFinishDownloadingTo")
        save(location, as: downloadTask.taskDescription ?? Self.savedFileName)
    }

    /// Called repeatedly as bytes arrive. Note the hop to the main thread:
    /// delegate callbacks do not arrive on it, and the UI needs it.
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        guard totalBytesExpectedToWrite > 0 else { return }
        let fraction = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        DispatchQueue.main.async { self.onProgress?(fraction) }
    }

    /// Called when the task ends, for success (error is nil) and for failure.
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {

        let message = error.map { "Failed: \($0.localizedDescription)" }
            ?? "Finished. See the log below."
        EventLog.shared.log("didCompleteWithError - \(error?.localizedDescription ?? "nil")")

        DispatchQueue.main.async { self.onFinish?(message) }
    }

    /// Every pending event has been delivered. Calling the stored handler tells
    /// the system it may suspend the app again. Never calling it makes the
    /// system treat your app as unresponsive.
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        EventLog.shared.log("urlSessionDidFinishEvents")
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}
