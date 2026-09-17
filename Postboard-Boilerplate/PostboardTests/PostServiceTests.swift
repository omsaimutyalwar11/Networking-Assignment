//
//  PostServiceTests.swift
//  PostboardTests
//
//  TASK 6 - unit tests for the GET: the success case and the error cases.
//
//  These never touch the internet. FakeServer (already written for you) sits
//  underneath URLSession and sends back whatever you tell it to, so you can
//  produce failures the real API would never give you.
//
//  Run the tests with Cmd-U.
//

import XCTest
@testable import Postboard

final class PostServiceTests: XCTestCase {

    private var service: PostService!

    override func setUp() {
        super.setUp()
        // The fake session goes in here, so no real request is ever made.
        service = PostService(session: FakeServer.makeSession())
    }

    override func tearDown() {
        // response is static, so it is shared between tests. One left
        // behind by an earlier test will quietly break the next one.
        FakeServer.response = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Worked example: read this one first

    func testSuccessDecodesPostsAndTotal() async throws {
        let json = """
        [ { "userId": 7, "id": 1, "title": "First", "body": "One" } ]
        """

        // What we want the fake server to send back.
        let statusCode = 200
        let body = Data(json.utf8)
        let headers = ["X-Total-Count": "100"]

        FakeServer.response = { _ in (statusCode, body, headers) }

        let page = try await service.fetchPosts(page: 1, limit: 10)

        XCTAssertEqual(page.posts.count, 1)
        XCTAssertEqual(page.totalCount, 100)
        XCTAssertEqual(page.posts[0].authorID, 7)   // proves your CodingKeys work
        XCTAssertEqual(page.posts[0].title, "First")
    }

    // MARK: - Your tests (Task 6)

    // TODO: a 404 should throw APIError.notFound.
    //
    //   let statusCode = 404
    //   let body = Data()
    //   let headers: [String: String] = [:]
    //   FakeServer.response = { _ in (statusCode, body, headers) }
    //
    // Then call fetchPosts and assert the error is that specific case - not
    // just that "some error" was thrown.

    // TODO: a 500 should throw APIError.badStatus(500).

    // TODO: a 200 whose body is the wrong shape, for example
    //
    //   let body = Data(#"{"nope": true}"#.utf8)
    //
    // must throw APIError.decodingFailed. If this one comes back as a success,
    // your send(_:) is not checking anything.

    // Tip: XCTAssertThrowsError does not work with async calls, so use
    // do/catch instead:
    //
    //   do {
    //       _ = try await service.fetchPosts(page: 1, limit: 10)
    //       XCTFail("expected an error")
    //   } catch let error as APIError {
    //       XCTAssertEqual(error, .notFound)
    //   }
}
