//
//  LoginMethod.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import Foundation

enum LoginMethod: String, Codable, CaseIterable, Identifiable {
    case apple = "apple"
    case google = "google"
    case microsoft = "microsoft"
    case github = "github"
    case facebook = "facebook"
    case linkedin = "linkedin"
    case emailPassword = "email_password"
    case magicLink = "magic_link"
    case smsOTP = "sms_otp"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .microsoft: return "Microsoft"
        case .github: return "GitHub"
        case .facebook: return "Facebook"
        case .linkedin: return "LinkedIn"
        case .emailPassword: return "Email/Password"
        case .magicLink: return "Magic Link"
        case .smsOTP: return "SMS/OTP"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .apple: return "apple.logo"
        case .google: return "g.circle.fill"
        case .microsoft: return "m.circle.fill"
        case .github: return "chevron.left.forwardslash.chevron.right"
        case .facebook: return "f.circle.fill"
        case .linkedin: return "l.circle.fill"
        case .emailPassword: return "envelope.fill"
        case .magicLink: return "link.circle.fill"
        case .smsOTP: return "message.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}
