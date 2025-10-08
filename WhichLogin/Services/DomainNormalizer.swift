//
//  DomainNormalizer.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import Foundation

class DomainNormalizer {
    static let shared = DomainNormalizer()
    
    private var publicSuffixList: Set<String> = []
    
    private init() {
        loadPublicSuffixList()
    }
    
    /// Normalize a domain to its eTLD+1 (effective top-level domain + 1)
    /// Example: "app.notion.so" -> "notion.so"
    func normalize(_ domain: String) -> String {
        let lowercased = domain.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Remove protocol if present
        var cleanDomain = lowercased
        if let range = cleanDomain.range(of: "://") {
            cleanDomain = String(cleanDomain[range.upperBound...])
        }
        
        // Remove path if present
        if let slashIndex = cleanDomain.firstIndex(of: "/") {
            cleanDomain = String(cleanDomain[..<slashIndex])
        }
        
        // Remove port if present
        if let colonIndex = cleanDomain.lastIndex(of: ":") {
            cleanDomain = String(cleanDomain[..<colonIndex])
        }
        
        // Split into components
        let components = cleanDomain.split(separator: ".").map(String.init)
        
        guard components.count >= 2 else {
            return cleanDomain
        }
        
        // Find the eTLD+1
        for i in (0..<components.count - 1).reversed() {
            let suffix = components[i...].joined(separator: ".")
            if publicSuffixList.contains(suffix) {
                if i > 0 {
                    return components[(i-1)...].joined(separator: ".")
                }
            }
        }
        
        // Default: return last two components
        return components.suffix(2).joined(separator: ".")
    }
    
    private func loadPublicSuffixList() {
        // Simplified list of common public suffixes
        // In production, this should be loaded from the full Public Suffix List
        publicSuffixList = [
            "com", "org", "net", "edu", "gov", "mil", "int",
            "co.uk", "org.uk", "ac.uk", "gov.uk",
            "com.au", "org.au", "net.au", "edu.au",
            "co.nz", "org.nz", "net.nz",
            "co.za", "org.za", "net.za",
            "com.br", "org.br", "net.br",
            "co.jp", "or.jp", "ne.jp", "ac.jp",
            "co.in", "org.in", "net.in", "ac.in",
            "com.cn", "org.cn", "net.cn", "edu.cn",
            "de", "fr", "it", "es", "nl", "be", "ch", "at",
            "se", "no", "dk", "fi", "pl", "cz", "ru",
            "ca", "mx", "ar", "cl", "co", "pe",
            "io", "ai", "app", "dev", "page", "so"
        ]
    }
}
