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

    enum CodingKeys: String, CodingKey {
        case id
        case authorID = "userId"
        case title
        case body
    }
}

/// What we send when creating a post. Encodable only: it never comes back.
struct NewPost: Encodable {

    let title: String
    let body: String
    let authorID: Int

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case authorID = "userId"
    }
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

    // Keys at the top level.
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
    }

    // Keys inside the "address" object.
    enum AddressKeys: String, CodingKey {
        case city
        case geo
    }

    // Keys inside the "geo" object.
    enum GeoKeys: String, CodingKey {
        case lat
    }

    init(from decoder: Decoder) throws {
        // Container for the top level object.
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode values that exist at the top level.
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        // Step into the nested "address" object.
        let addressContainer = try container.nestedContainer(keyedBy: AddressKeys.self, forKey: .address)

        // Decode "city" from inside "address".
        city = try addressContainer.decode(String.self, forKey: .city)

        // Step into the nested "geo" object inside "address".
        let geoContainer = try addressContainer.nestedContainer(keyedBy: GeoKeys.self, forKey: .geo)

        // Decode "lat" from inside "geo".
        latitude = try geoContainer.decode(String.self, forKey: .lat)
    }
}
