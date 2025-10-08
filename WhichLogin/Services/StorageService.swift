//
//  StorageService.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import Foundation
import CryptoKit
import Combine

@MainActor
class StorageService: ObservableObject {
    static let shared = StorageService()
    
    @Published var preferences: [SiteLoginPreference] = []
    @Published var settings: AppSettings = AppSettings()
    
    private let preferencesFileName = "site_preferences.json"
    private let settingsFileName = "settings.json"
    
    private var containerURL: URL? {
        // For development without App Group entitlements, use Application Support
        // In production with proper signing, use App Group container
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("WhichLogin", isDirectory: true)
    }
    
    private init() {
        loadSettings()
        loadPreferences()
    }
    
    // MARK: - Preferences Management
    
    func loadPreferences() {
        guard let url = containerURL?.appendingPathComponent(preferencesFileName) else {
            print("Failed to get container URL")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decryptedData = try decrypt(data)
            preferences = try JSONDecoder().decode([SiteLoginPreference].self, from: decryptedData)
        } catch {
            print("Failed to load preferences: \(error.localizedDescription)")
            preferences = []
        }
    }
    
    func savePreferences() {
        guard let containerURL = containerURL else {
            print("Failed to get container URL")
            return
        }
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
        
        let url = containerURL.appendingPathComponent(preferencesFileName)
        
        do {
            let data = try JSONEncoder().encode(preferences)
            let encryptedData = try encrypt(data)
            try encryptedData.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save preferences: \(error.localizedDescription)")
        }
    }
    
    func getPreference(for site: String) -> SiteLoginPreference? {
        preferences.first { $0.site == site }
    }
    
    func updatePreference(_ preference: SiteLoginPreference) {
        if let index = preferences.firstIndex(where: { $0.id == preference.id }) {
            preferences[index] = preference
        } else {
            preferences.append(preference)
        }
        savePreferences()
    }
    
    func recordLogin(site: String, method: LoginMethod) {
        if var existing = getPreference(for: site) {
            existing.recordMethod(method)
            updatePreference(existing)
        } else {
            let newPreference = SiteLoginPreference(
                site: site,
                lastMethod: method,
                history: [SiteLoginPreference.HistoryEntry(method: method)]
            )
            updatePreference(newPreference)
        }
    }
    
    func deletePreference(_ preference: SiteLoginPreference) {
        preferences.removeAll { $0.id == preference.id }
        savePreferences()
    }
    
    func clearAllPreferences() {
        preferences.removeAll()
        savePreferences()
    }
    
    // MARK: - Settings Management
    
    func loadSettings() {
        guard let url = containerURL?.appendingPathComponent(settingsFileName) else {
            print("Failed to get container URL")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            settings = try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            print("Failed to load settings: \(error.localizedDescription)")
            settings = AppSettings()
        }
    }
    
    func saveSettings() {
        guard let containerURL = containerURL else {
            print("Failed to get container URL")
            return
        }
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
        
        let url = containerURL.appendingPathComponent(settingsFileName)
        
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save settings: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Export/Import
    
    func exportToJSON() throws -> Data {
        let exportData = ExportData(preferences: preferences, settings: settings)
        return try JSONEncoder().encode(exportData)
    }
    
    func importFromJSON(_ data: Data) throws {
        let importData = try JSONDecoder().decode(ExportData.self, from: data)
        self.preferences = importData.preferences
        self.settings = importData.settings
        savePreferences()
        saveSettings()
    }
    
    // MARK: - Encryption
    
    private func getEncryptionKey() throws -> SymmetricKey {
        let keyData: Data
        
        if let existingKey = try? getKeychainKey() {
            keyData = existingKey
        } else {
            keyData = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
            try saveKeychainKey(keyData)
        }
        
        return SymmetricKey(data: keyData)
    }
    
    private func encrypt(_ data: Data) throws -> Data {
        let key = try getEncryptionKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }
    
    private func decrypt(_ data: Data) throws -> Data {
        let key = try getEncryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    // MARK: - Keychain
    
    private func getKeychainKey() throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "WhichLoginEncryptionKey",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        
        return result as? Data
    }
    
    private func saveKeychainKey(_ key: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "WhichLoginEncryptionKey",
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}

// MARK: - Export Data Model

private struct ExportData: Codable {
    let preferences: [SiteLoginPreference]
    let settings: AppSettings
}
