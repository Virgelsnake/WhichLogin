//
//  SiteLoginPreference.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import Foundation

struct SiteLoginPreference: Codable, Identifiable {
    let id: UUID
    var site: String // eTLD+1 domain
    var lastMethod: LoginMethod
    var history: [HistoryEntry]
    var lastSeenAt: Date
    var timesSeen: Int
    var ignored: Bool
    
    init(
        id: UUID = UUID(),
        site: String,
        lastMethod: LoginMethod,
        history: [HistoryEntry] = [],
        lastSeenAt: Date = Date(),
        timesSeen: Int = 1,
        ignored: Bool = false
    ) {
        self.id = id
        self.site = site
        self.lastMethod = lastMethod
        self.history = history
        self.lastSeenAt = lastSeenAt
        self.timesSeen = timesSeen
        self.ignored = ignored
    }
    
    struct HistoryEntry: Codable, Identifiable {
        let id: UUID
        let method: LoginMethod
        let timestamp: Date
        
        init(id: UUID = UUID(), method: LoginMethod, timestamp: Date = Date()) {
            self.id = id
            self.method = method
            self.timestamp = timestamp
        }
    }
    
    mutating func recordMethod(_ method: LoginMethod) {
        self.lastMethod = method
        self.lastSeenAt = Date()
        self.timesSeen += 1
        self.history.append(HistoryEntry(method: method))
        
        // Keep only last 10 entries
        if history.count > 10 {
            history = Array(history.suffix(10))
        }
    }
}
