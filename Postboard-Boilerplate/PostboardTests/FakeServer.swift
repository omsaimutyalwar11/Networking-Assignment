//
//  FakeServer.swift
//  PostboardTests
//
//  GIVEN - you do not need to change this file, just use it.
//
//  A fake server that sits underneath URLSession. Instead of going to the
//  internet, the session asks this class what to send back, so your tests are
//  fast, work offline, and can produce failures the real API never would.
//
//  Use it like this:
//
//      let statusCode = 404
//      let body = Data()
//      let headers: [String: String] = [:]
//
//      FakeServer.response = { _ in (statusCode, body, headers) }
//
//  and every request made through FakeServer.makeSession() gets a 404.
//

import Foundation

/// What the fake server sends back for one request.
typealias StubbedResponse = (statusCode: Int, body: Data, headers: [String: String])

final class FakeServer: URLProtocol {

    /// Given the request, return the response to reply with. Throwing from
    /// inside it simulates the request never reaching a server at all.
    nonisolated(unsafe) static var response: ((URLRequest) throws -> StubbedResponse)?

    /// A URLSession that talks to this fake instead of the network.
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [FakeServer.self]
        return URLSession(configuration: configuration)
    }

    // MARK: - URLProtocol plumbing

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let makeResponse = FakeServer.response else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let stub = try makeResponse(request)

            let httpResponse = HTTPURLResponse(url: request.url!,
                                               statusCode: stub.statusCode,
                                               httpVersion: "HTTP/1.1",
                                               headerFields: stub.headers)!

            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: stub.body)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
