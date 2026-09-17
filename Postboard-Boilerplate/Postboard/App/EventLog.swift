//
//  EventLog.swift
//  Postboard
//
//  GIVEN - you do not need to change this file, but you will use it a lot.
//
//  Why not just print()? Because for the background download the system kills
//  your app and starts it again later. The Xcode console is long gone by then,
//  so print() output is lost. This writes to UserDefaults instead, and the
//  main screen shows it, so you can see what happened while you were away.
//

import Foundation

final class EventLog {

    static let shared = EventLog()
    static let didChange = Notification.Name("EventLogDidChange")

    private let key = "EventLog.lines"

    private init() {}

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    func log(_ message: String) {
        let line = "[\(Self.formatter.string(from: Date()))] \(message)"
        print(line)

        var lines = UserDefaults.standard.stringArray(forKey: key) ?? []
        lines.append(line)
        if lines.count > 100 { lines.removeFirst(lines.count - 100) }
        UserDefaults.standard.set(lines, forKey: key)

        // Delegate callbacks are not on the main thread, and observers of this
        // notification update the UI, so hop here once rather than everywhere.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Self.didChange, object: nil)
        }
    }

    var lines: [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        NotificationCenter.default.post(name: Self.didChange, object: nil)
    }
}
