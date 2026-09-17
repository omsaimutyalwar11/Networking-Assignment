//
//  PostService.swift
//  Postboard
//
//  TASKS 2, 3 and 4 - all the networking for this app.
//
//  ---------------------------------------------------------------------------
//  BEFORE YOU WRITE ANY CODE, open these in your browser.
//
//  Seeing the real response first makes the Swift much easier to write, and
//  you can experiment without rebuilding the app. Change the numbers in the
//  address bar and press Enter to see what happens.
//
//    Every post (100 of them):
//      https://jsonplaceholder.typicode.com/posts
//
//    The first 10 - this is what the app asks for on launch:
//      https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
//
//    The next 10 - change _page and watch the ids change with it:
//      https://jsonplaceholder.typicode.com/posts?_page=2&_limit=10
//
//    Five at a time instead of ten:
//      https://jsonplaceholder.typicode.com/posts?_page=1&_limit=5
//
//    A single post:
//      https://jsonplaceholder.typicode.com/posts/1
//
//    A post that does not exist - answers 404. You will need this one when
//    you get to the tests in Task 6:
//      https://jsonplaceholder.typicode.com/posts/99999
//
//  Play with it. Try _page=11 (past the end), or _limit=0. Look at what comes
//  back before you decide how your code should behave.
//
//  Three things to notice while you are there:
//
//    1. Each post has "userId", not "authorID". That is Task 1.
//
//    2. Page 1 gives ids 1-10, page 2 gives ids 11-20. Nothing in the body
//       tells you there are 100 posts altogether.
//
//    3. That total comes back in a response HEADER named X-Total-Count. To
//       see it: press F12 for developer tools, open the Network tab, reload
//       the page, click the request, and look under Response Headers. This is
//       why send(_:) below gives you the HTTPURLResponse as well as the data.
//  ---------------------------------------------------------------------------
//

import Foundation

/// The screen talks to this protocol, never to URLSession. That is what lets
/// your tests swap in a fake server, and what keeps networking out of the view
/// controller. Do not change it - the given UI is written against it.
protocol PostServiceProtocol {
    func fetchPosts(page: Int, limit: Int) async throws -> Page
    func createPost(_ post: NewPost) async throws -> Post
}

final class PostService: PostServiceProtocol {

    private let session: URLSession
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    /// Keep this initialiser exactly as it is. Your tests pass a fake session
    /// in here so they never touch the real network.
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Task 2: the GET

    /// GET /posts?_page=<page>&_limit=<limit>
    ///
    /// Steps:
    ///  1. build the URL with URLComponents and queryItems - not by joining
    ///     strings, which would break the moment a value needs escaping
    ///  2. make a URLRequest, httpMethod "GET"
    ///  3. pass it to send(_:) below
    ///  4. decode [Post] from the data
    ///  5. Task 3: read "X-Total-Count" off the response for Page.totalCount
    func fetchPosts(page: Int, limit: Int) async throws -> Page {
        // TODO (Tasks 2 and 3)
        throw APIError.transport("fetchPosts is not written yet")
    }

    // MARK: - Task 4: the POST

    /// POST /posts with a JSON body. The server replies with the post it
    /// created, including the id it assigned.
    ///
    /// Steps: set httpMethod, set the "Content-Type" header to
    /// "application/json", encode the NewPost with JSONEncoder into httpBody,
    /// send it, and decode the Post that comes back.
    func createPost(_ post: NewPost) async throws -> Post {
        // TODO (Task 4)
        throw APIError.transport("createPost is not written yet")
    }

    // MARK: - Shared plumbing

    /// Sends the request and returns the body ONLY if the status says it is
    /// worth reading.
    ///
    /// This is the most important method in the file. "No error was thrown"
    /// does not mean the request worked: a 404 and a 500 both arrive with no
    /// error at all and a perfectly readable body. If you skip this check and
    /// decode anyway, the user sees a confusing decoding message instead of
    /// "we could not find that".
    ///
    /// Steps:
    ///  1. call session.data(for: request) inside a do/catch
    ///  2. catch URLError - if the code is .notConnectedToInternet throw
    ///     APIError.offline, otherwise APIError.transport
    ///  3. cast the URLResponse to HTTPURLResponse
    ///  4. switch on http.statusCode:
    ///       200..<300  ->  return (data, http)
    ///       404        ->  throw APIError.notFound
    ///       anything else -> throw APIError.badStatus(that code)
    private func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        // TODO (Task 2)
        throw APIError.transport("send is not written yet")
    }

    /// Turns the response body into whatever model you ask for, in one place,
    /// so that every decoding failure is reported the same way.
    ///
    /// Call it as decode([Post].self, from: data) or decode(Post.self, from: data).
    ///
    /// Steps:
    ///  1. try JSONDecoder().decode(type, from: data) inside a do/catch
    ///  2. on failure, log the real error with EventLog - you will need that
    ///     detail when your CodingKeys are wrong, and it is the only place it
    ///     appears
    ///  3. then throw APIError.decodingFailed, which is what the user sees.
    ///     Never put the raw decoding detail in front of a user.
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        // TODO (Task 2)
        throw APIError.transport("decode is not written yet")
    }
}
