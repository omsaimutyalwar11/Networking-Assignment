//
//  APIError.swift
//  Postboard
//
//  TASK 2 (part 2) - one error type for the whole networking layer.
//
//  The screen never looks at a status code. It asks this type for a message
//  and shows it. Keep it that way.
//

import Foundation

enum APIError: Error, Equatable {

    /// We could not even build the URL. A bug in our code, not the server's.
    case invalidURL

    /// The server said 404.
    case notFound

    /// Any other status that is not a success, with the code.
    case badStatus(Int)

    /// No internet connection.
    case offline

    /// The bytes arrived, but they did not match our model.
    case decodingFailed

    /// Anything else that stopped the request reaching the server.
    case transport(String)

    /// What the user is shown. Say what they can do about it where you can.
    var userMessage: String {
        switch self {
        case .invalidURL:
            return "The app built an invalid request. Please report this."
        case .notFound:
            return "We could not find what you asked for."
        case .badStatus(let code):
            return "The server could not handle that request (\(code)). Please try again."
        case .offline:
            return "You appear to be offline. Check your connection and try again."
        case .decodingFailed:
            // The details go to the log, never to the user.
            return "The server sent data in a format the app did not expect."
        case .transport(let detail):
            return "Could not reach the server. \(detail)"
        }
    }
}
