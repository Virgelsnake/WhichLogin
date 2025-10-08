//
//  DomainNormalizerTests.swift
//  WhichLoginTests
//
//  Created on 2025-10-08.
//

import XCTest
@testable import WhichLogin

final class DomainNormalizerTests: XCTestCase {
    
    var normalizer: DomainNormalizer!
    
    override func setUp() {
        super.setUp()
        normalizer = DomainNormalizer.shared
    }
    
    func testBasicDomainNormalization() {
        XCTAssertEqual(normalizer.normalize("example.com"), "example.com")
        XCTAssertEqual(normalizer.normalize("www.example.com"), "example.com")
        XCTAssertEqual(normalizer.normalize("app.example.com"), "example.com")
    }
    
    func testSubdomainNormalization() {
        XCTAssertEqual(normalizer.normalize("app.notion.so"), "notion.so")
        XCTAssertEqual(normalizer.normalize("mail.google.com"), "google.com")
        XCTAssertEqual(normalizer.normalize("login.microsoftonline.com"), "microsoftonline.com")
    }
    
    func testProtocolRemoval() {
        XCTAssertEqual(normalizer.normalize("https://example.com"), "example.com")
        XCTAssertEqual(normalizer.normalize("http://example.com"), "example.com")
        XCTAssertEqual(normalizer.normalize("https://www.example.com"), "example.com")
    }
    
    func testPathRemoval() {
        XCTAssertEqual(normalizer.normalize("example.com/login"), "example.com")
        XCTAssertEqual(normalizer.normalize("example.com/auth/signin"), "example.com")
        XCTAssertEqual(normalizer.normalize("https://example.com/path/to/page"), "example.com")
    }
    
    func testPortRemoval() {
        XCTAssertEqual(normalizer.normalize("example.com:8080"), "example.com")
        XCTAssertEqual(normalizer.normalize("localhost:3000"), "localhost")
    }
    
    func testCoUkDomains() {
        XCTAssertEqual(normalizer.normalize("www.bbc.co.uk"), "bbc.co.uk")
        XCTAssertEqual(normalizer.normalize("news.bbc.co.uk"), "bbc.co.uk")
    }
    
    func testCaseInsensitivity() {
        XCTAssertEqual(normalizer.normalize("EXAMPLE.COM"), "example.com")
        XCTAssertEqual(normalizer.normalize("Example.Com"), "example.com")
    }
}
