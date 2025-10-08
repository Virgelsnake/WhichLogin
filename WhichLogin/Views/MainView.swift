//
//  MainView.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var storageService: StorageService
    @State private var searchText = ""
    @State private var selectedPreference: SiteLoginPreference?
    @State private var showingSettings = false
    
    var filteredPreferences: [SiteLoginPreference] {
        if searchText.isEmpty {
            return storageService.preferences.sorted { $0.lastSeenAt > $1.lastSeenAt }
        } else {
            return storageService.preferences
                .filter { $0.site.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.lastSeenAt > $1.lastSeenAt }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("WhichLogin")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingSettings.toggle() }) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding()
            
            Divider()
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search sites...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // List
            if filteredPreferences.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "key.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text(searchText.isEmpty ? "No sites tracked yet" : "No matching sites")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if searchText.isEmpty {
                        Text("Sign in to websites to start tracking")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredPreferences) { preference in
                    SiteRow(preference: preference)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPreference = preference
                        }
                }
                .listStyle(.plain)
            }
            
            Divider()
            
            // Footer
            HStack {
                Text("\(storageService.preferences.count) sites")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Clear All") {
                    storageService.clearAllPreferences()
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                .disabled(storageService.preferences.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 400, height: 500)
        .sheet(item: $selectedPreference) { preference in
            EditPreferenceView(preference: preference)
                .environmentObject(storageService)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(storageService)
        }
    }
}

struct SiteRow: View {
    let preference: SiteLoginPreference
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: preference.lastMethod.iconName)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(preference.site)
                    .font(.body)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(preference.lastMethod.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(preference.lastSeenAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if preference.ignored {
                Image(systemName: "eye.slash")
                    .foregroundColor(.secondary)
                    .help("Ignored")
            }
            
            Text("\(preference.timesSeen)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}
