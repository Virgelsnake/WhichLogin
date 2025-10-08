//
//  SettingsView.swift
//  WhichLogin
//
//  Created on 2025-10-08.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var storageService: StorageService
    @Environment(\.dismiss) var dismiss
    
    @State private var showingExportPanel = false
    @State private var showingImportPanel = false
    @State private var exportError: String?
    @State private var importError: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            Form {
                Section("Hint Display") {
                    Toggle("Show hints on login pages", isOn: $storageService.settings.showHint)
                        .onChange(of: storageService.settings.showHint) { _ in
                            storageService.saveSettings()
                        }
                    
                    Picker("Position", selection: $storageService.settings.hintPosition) {
                        ForEach(AppSettings.HintPosition.allCases, id: \.self) { position in
                            Text(position.displayName).tag(position)
                        }
                    }
                    .onChange(of: storageService.settings.hintPosition) { _ in
                        storageService.saveSettings()
                    }
                    
                    HStack {
                        Text("Timeout")
                        Spacer()
                        TextField("", value: $storageService.settings.hintTimeoutMs, format: .number)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        Text("ms")
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: storageService.settings.hintTimeoutMs) { _ in
                        storageService.saveSettings()
                    }
                }
                
                Section("Data") {
                    Button(action: exportData) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: importData) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                    
                    if let error = exportError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if let error = importError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Sites tracked", value: "\(storageService.preferences.count)")
                }
                
                Section("Privacy") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WhichLogin stores all data locally on your device.")
                            .font(.caption)
                        Text("No passwords, emails, or personal information are collected.")
                            .font(.caption)
                        Text("Data is encrypted at rest using CryptoKit.")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 400, height: 500)
        .fileExporter(
            isPresented: $showingExportPanel,
            document: ExportDocument(data: try? storageService.exportToJSON()),
            contentType: .json,
            defaultFilename: "whichlogin-export.json"
        ) { result in
            switch result {
            case .success:
                exportError = nil
            case .failure(let error):
                exportError = error.localizedDescription
            }
        }
        .fileImporter(
            isPresented: $showingImportPanel,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                do {
                    let data = try Data(contentsOf: url)
                    try storageService.importFromJSON(data)
                    importError = nil
                } catch {
                    importError = error.localizedDescription
                }
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
    }
    
    private func exportData() {
        showingExportPanel = true
    }
    
    private func importData() {
        showingImportPanel = true
    }
}

struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data?
    
    init(data: Data?) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = data else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
