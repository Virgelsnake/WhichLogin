//
//  WhichLoginApp.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import SwiftUI

@main
struct WhichLoginApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var storageService = StorageService.shared
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(storageService)
        }
    }
}
