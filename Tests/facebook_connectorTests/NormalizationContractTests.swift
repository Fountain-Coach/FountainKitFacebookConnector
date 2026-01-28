import Foundation
import XCTest
@testable import facebook_connector

final class NormalizationContractTests: XCTestCase {
    func testNormalizeFixturesDeterministically() throws {
        let graphData = try loadFixture(path: "fixtures/graph/me_posts.json")
        let expectedData = try loadFixture(path: "fixtures/idl/posts.json")

        let actual = try FacebookNormalizer.normalizeUserPostsResponse(graphData).posts
        let expected = try JSONDecoder().decode([Post].self, from: expectedData)

        XCTAssertEqual(actual, expected)
    }

    func testUnknownFieldsAreIgnored() throws {
        var object = try loadJSONObject(path: "fixtures/graph/me_posts.json")
        object["unexpected"] = ["nested": ["field": 123]]
        let data = try JSONSerialization.data(withJSONObject: object, options: [])

        let normalized = try FacebookNormalizer.normalizeUserPostsResponse(data).posts
        XCTAssertFalse(normalized.isEmpty)
    }

    func testMissingOptionalFieldsDoNotCrash() throws {
        var object = try loadJSONObject(path: "fixtures/graph/me_posts.json")
        var data = object["data"] as? [[String: Any]] ?? []
        XCTAssertFalse(data.isEmpty)
        data[0].removeValue(forKey: "message")
        data[0].removeValue(forKey: "attachments")
        object["data"] = data

        let raw = try JSONSerialization.data(withJSONObject: object, options: [])
        let normalized = try FacebookNormalizer.normalizeUserPostsResponse(raw).posts
        XCTAssertEqual(normalized.first?.id, "post_1")
        XCTAssertNil(normalized.first?.text)
        XCTAssertTrue((normalized.first?.images ?? []).isEmpty)
    }

    func testVideoItemsAreNeverEmitted() throws {
        let graphData = try loadFixture(path: "fixtures/graph/me_posts.json")
        let posts = try FacebookNormalizer.normalizeUserPostsResponse(graphData).posts

        for post in posts {
            for image in post.images {
                XCTAssertEqual(image.source, "facebook")
                XCTAssertEqual(image.postId, post.id)
                XCTAssertFalse(image.url.lowercased().contains(".mp4"))
                XCTAssertFalse(image.url.lowercased().contains(".mov"))
                XCTAssertFalse(image.url.lowercased().contains(".m4v"))
            }
        }
    }

    // MARK: - Fixture helpers

    private func packageRoot() -> URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent() // facebook_connectorTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // package root
    }

    private func loadFixture(path: String) throws -> Data {
        let url = packageRoot().appendingPathComponent(path)
        return try Data(contentsOf: url)
    }

    private func loadJSONObject(path: String) throws -> [String: Any] {
        let data = try loadFixture(path: path)
        let raw = try JSONSerialization.jsonObject(with: data, options: [])
        return raw as? [String: Any] ?? [:]
    }
}
