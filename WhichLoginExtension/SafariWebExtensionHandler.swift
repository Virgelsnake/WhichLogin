//
//  SafariWebExtensionHandler.swift
//  WhichLoginExtension
//
//  Created on 2025-10-08.
//

import SafariServices
import os.log

@MainActor
class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    private let storageService = StorageService.shared
    
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem
        
        guard let message = request?.userInfo?[SFExtensionMessageKey] as? [String: Any],
              let messageName = message["name"] as? String else {
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        os_log(.default, "Received message: %{public}@", messageName)
        
        Task { @MainActor in
            let response: [String: Any]
            
            switch messageName {
            case "getPreference":
                response = await handleGetPreference(message)
            case "recordLogin":
                response = await handleRecordLogin(message)
            case "getSettings":
                response = await handleGetSettings()
            default:
                response = ["error": "Unknown message type"]
            }
            
            let responseItem = NSExtensionItem()
            responseItem.userInfo = [SFExtensionMessageKey: response]
            context.completeRequest(returningItems: [responseItem], completionHandler: nil)
        }
    }
    
    @MainActor
    private func handleGetPreference(_ message: [String: Any]) async -> [String: Any] {
        guard let site = message["site"] as? String else {
            return ["error": "Missing site parameter"]
        }
        
        let normalizedSite = DomainNormalizer.shared.normalize(site)
        
        if let preference = storageService.getPreference(for: normalizedSite) {
            return [
                "site": preference.site,
                "method": preference.lastMethod.rawValue,
                "ignored": preference.ignored
            ]
        }
        
        return ["found": false]
    }
    
    @MainActor
    private func handleRecordLogin(_ message: [String: Any]) async -> [String: Any] {
        guard let site = message["site"] as? String,
              let methodString = message["method"] as? String,
              let method = LoginMethod(rawValue: methodString) else {
            return ["error": "Missing or invalid parameters"]
        }
        
        let normalizedSite = DomainNormalizer.shared.normalize(site)
        storageService.recordLogin(site: normalizedSite, method: method)
        
        return ["success": true]
    }
    
    @MainActor
    private func handleGetSettings() async -> [String: Any] {
        return [
            "showHint": storageService.settings.showHint,
            "hintPosition": storageService.settings.hintPosition.rawValue,
            "hintTimeoutMs": storageService.settings.hintTimeoutMs
        ]
    }
}
