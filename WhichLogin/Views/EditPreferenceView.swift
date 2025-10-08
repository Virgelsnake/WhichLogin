//
//  EditPreferenceView.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import SwiftUI

struct EditPreferenceView: View {
    @EnvironmentObject var storageService: StorageService
    @Environment(\.dismiss) var dismiss
    
    @State private var preference: SiteLoginPreference
    
    init(preference: SiteLoginPreference) {
        _preference = State(initialValue: preference)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Site")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    storageService.updatePreference(preference)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            Form {
                Section("Site") {
                    HStack {
                        Text(preference.site)
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                }
                
                Section("Login Method") {
                    Picker("Method", selection: $preference.lastMethod) {
                        ForEach(LoginMethod.allCases) { method in
                            HStack {
                                Image(systemName: method.iconName)
                                Text(method.displayName)
                            }
                            .tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Options") {
                    Toggle("Ignore this site", isOn: $preference.ignored)
                        .help("Don't show hints for this site")
                }
                
                Section("Statistics") {
                    LabeledContent("Times seen", value: "\(preference.timesSeen)")
                    LabeledContent("Last seen", value: preference.lastSeenAt.formatted(date: .abbreviated, time: .shortened))
                }
                
                if !preference.history.isEmpty {
                    Section("History") {
                        ForEach(preference.history.reversed()) { entry in
                            HStack {
                                Image(systemName: entry.method.iconName)
                                    .foregroundColor(.accentColor)
                                Text(entry.method.displayName)
                                Spacer()
                                Text(entry.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        storageService.deletePreference(preference)
                        dismiss()
                    } label: {
                        Label("Delete Site", systemImage: "trash")
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 400, height: 500)
    }
}
