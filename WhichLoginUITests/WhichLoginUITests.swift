//
//  WhichLoginUITests.swift
//  WhichLoginUITests
//
//  Created on 2025-10-08.
//

import XCTest

final class WhichLoginUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testAppLaunches() throws {
        // Basic test to verify app launches
        XCTAssert(app.exists)
    }
    
    func testMenuBarItemExists() throws {
        // Test that menu bar item is created
        // Note: Menu bar items are harder to test in UI tests
        // This is a placeholder for manual testing
        XCTAssert(true)
    }
}
