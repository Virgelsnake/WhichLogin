//
//  AppSettings.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import Foundation

struct AppSettings: Codable {
    var showHint: Bool
    var hintPosition: HintPosition
    var hintTimeoutMs: Int
    var language: String
    
    init(
        showHint: Bool = true,
        hintPosition: HintPosition = .bottomRight,
        hintTimeoutMs: Int = 6000,
        language: String = "en-GB"
    ) {
        self.showHint = showHint
        self.hintPosition = hintPosition
        self.hintTimeoutMs = hintTimeoutMs
        self.language = language
    }
    
    enum HintPosition: String, Codable, CaseIterable {
        case bottomRight = "bottom_right"
        case bottomLeft = "bottom_left"
        case topRight = "top_right"
        case topLeft = "top_left"
        
        var displayName: String {
            switch self {
            case .bottomRight: return "Bottom Right"
            case .bottomLeft: return "Bottom Left"
            case .topRight: return "Top Right"
            case .topLeft: return "Top Left"
            }
        }
    }
}
