//
//  Models.swift
//  Postboard
//
//  TASK 1 - the models.
//
//  Open this in your browser first:
//    https://jsonplaceholder.typicode.com/posts/1
//
//  Compare what you see with the properties below. The server says "userId";
//  we say authorID. Keep our name - APIs rarely use the names you would pick,
//  and mapping between the two is exactly what this task is about.
//
//  These compile as they are, but they do not decode yet. Run the app and read
//  the error.
//

import Foundation

struct Post: Decodable, Equatable {

    let id: Int
    let authorID: Int
    let title: String
    let body: String

    // TODO (Task 1): add a CodingKeys enum so authorID reads from "userId".
}

/// What we send when creating a post. Encodable only: it never comes back.
struct NewPost: Encodable {

    let title: String
    let body: String
    let authorID: Int

    // TODO (Task 1): the server expects "userId" here too.
}

/// One page of posts, plus how many exist in total. Nothing to change.
struct Page: Equatable {
    let posts: [Post]
    let totalCount: Int
}

// MARK: - Stretch task only

/// STRETCH (Task 7) - do not start this until Tasks 1 to 6 are working.
///
/// Open https://jsonplaceholder.typicode.com/users/1 in your browser. Notice
/// that "city" is inside "address", and "lat" is inside "address" -> "geo".
/// We want them flat here, without inventing extra structs to reach them.
///
/// As written this compiles but looks for "city" at the top level, so it will fail at runtime. Write init(from:) yourself instead.
/// Refer section "5.4.1 Writing init(from:) yourself" in the training document to brush up on this.
struct Author: Decodable, Equatable {

    let id: Int
    let name: String
    let city: String
    let latitude: String

    // TODO (Stretch):
    //  1. one CodingKey enum per level - the keys differ at each level, so a
    //     single enum cannot describe them all
    //  2. init(from decoder: Decoder)
    //  3. container.nestedContainer(keyedBy:forKey:) steps down one level
}
