//
//  StorageServiceTests.swift
//  WhichLoginTests
//
//  Created on 2025-10-08.
//

import XCTest
@testable import WhichLogin

final class StorageServiceTests: XCTestCase {
    
    var storageService: StorageService!
    
    @MainActor
    override func setUp() {
        super.setUp()
        storageService = StorageService.shared
        storageService.clearAllPreferences()
    }
    
    @MainActor
    func testRecordLogin() {
        let site = "example.com"
        let method = LoginMethod.google
        
        storageService.recordLogin(site: site, method: method)
        
        let preference = storageService.getPreference(for: site)
        XCTAssertNotNil(preference)
        XCTAssertEqual(preference?.site, site)
        XCTAssertEqual(preference?.lastMethod, method)
        XCTAssertEqual(preference?.timesSeen, 1)
    }
    
    @MainActor
    func testUpdateExistingPreference() {
        let site = "example.com"
        
        storageService.recordLogin(site: site, method: .google)
        storageService.recordLogin(site: site, method: .apple)
        
        let preference = storageService.getPreference(for: site)
        XCTAssertEqual(preference?.lastMethod, .apple)
        XCTAssertEqual(preference?.timesSeen, 2)
        XCTAssertEqual(preference?.history.count, 2)
    }
    
    @MainActor
    func testDeletePreference() {
        let site = "example.com"
        storageService.recordLogin(site: site, method: .google)
        
        var preference = storageService.getPreference(for: site)
        XCTAssertNotNil(preference)
        
        storageService.deletePreference(preference!)
        preference = storageService.getPreference(for: site)
        XCTAssertNil(preference)
    }
    
    @MainActor
    func testClearAllPreferences() {
        storageService.recordLogin(site: "example1.com", method: .google)
        storageService.recordLogin(site: "example2.com", method: .apple)
        
        XCTAssertEqual(storageService.preferences.count, 2)
        
        storageService.clearAllPreferences()
        XCTAssertEqual(storageService.preferences.count, 0)
    }
    
    @MainActor
    func testHistoryLimit() {
        let site = "example.com"
        
        // Record 15 logins
        for _ in 0..<15 {
            storageService.recordLogin(site: site, method: .google)
        }
        
        let preference = storageService.getPreference(for: site)
        // Should keep only last 10
        XCTAssertEqual(preference?.history.count, 10)
    }
}
