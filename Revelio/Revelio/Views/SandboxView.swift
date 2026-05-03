//
//  SandboxView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//
import SwiftUI
import WebKit

// MARK: - WKWebView wrapper
struct SafeWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = false
        config.defaultWebpagePreferences = pagePrefs
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Sandbox Web Sheet
struct SandboxWebSheet: View {
    let urlString: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundColor(.orange)
                    Text("You are viewing this link in a sandboxed environment. JavaScript is disabled.")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.2))

                if let url = URL(string: urlString) {
                    SafeWebView(url: url)
                } else {
                    Spacer()
                    Text("Invalid URL")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .navigationTitle("Sandboxed Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Attachment Preview Sheet
struct AttachmentPreviewSheet: View {
    let assetName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if UIImage(named: assetName) != nil {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Preview not available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .navigationTitle(assetName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Attachment Helper
struct AttachmentInfo {
    let filename: String
    let isBlocked: Bool
    let fileType: String
    let simulatedSize: String
    let icon: String

    static let blockedExtensions = [".exe", ".sh", ".dmg", ".bat", ".js", ".py", ".rb", ".pl"]
    static let safeExtensions: [String: (icon: String, type: String)] = [
        ".pdf": ("doc.richtext", "PDF Document"),
        ".txt": ("doc.text", "Plain Text"),
        ".docx": ("doc.fill", "Word Document"),
        ".xlsx": ("tablecells", "Spreadsheet"),
        ".jpg": ("photo", "JPEG Image"),
        ".png": ("photo", "PNG Image"),
        ".zip": ("archivebox", "ZIP Archive")
    ]

    // Asset name is filename without extension
    var assetName: String {
        let parts = filename.components(separatedBy: ".")
        let result = parts.dropLast().joined(separator: ".")
        return result
    }

    init(filename: String) {
        self.filename = filename
        let lower = filename.lowercased()
        let ext = "." + (lower.components(separatedBy: ".").last ?? "")
        self.isBlocked = AttachmentInfo.blockedExtensions.contains(ext)

        if let safe = AttachmentInfo.safeExtensions[ext] {
            self.icon = safe.icon
            self.fileType = safe.type
        } else if self.isBlocked {
            self.icon = "exclamationmark.triangle.fill"
            self.fileType = "\(ext.uppercased().dropFirst()) File — Executable"
        } else {
            self.icon = "doc.fill"
            self.fileType = "Unknown File"
        }

        let sizes = ["12 KB", "48 KB", "256 KB", "1.2 MB", "3.4 MB"]
        self.simulatedSize = sizes[abs(filename.hashValue) % sizes.count]
    }
}

// MARK: - Attachment Row
struct AttachmentRow: View {
    let info: AttachmentInfo
    let onPreviewTapped: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: info.icon)
                    .foregroundColor(info.isBlocked ? .red : .teal)
                    .font(.title3)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.filename)
                        .font(.subheadline.bold())
                        .foregroundColor(.black)
                    Text(info.fileType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if info.isBlocked {
                    Text("blocked")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.red.opacity(0.8)))
                } else {
                    Button {
                        onPreviewTapped(info.assetName)
                    } label: {
                        Text("Preview")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.teal.opacity(0.25)))
                    }
                }
            }

            // Metadata
            if !info.isBlocked {
                HStack(spacing: 16) {
                    Label("Size: \(info.simulatedSize)", systemImage: "externaldrive")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Label(info.fileType, systemImage: "tag")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 38)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield")
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.7))
                    Text("This file type can execute code and has been blocked for your safety.")
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.7))
                }
                .padding(.leading, 38)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(info.isBlocked ? Color.red.opacity(0.05) : Color.teal.opacity(0.05))
        )
    }
}

// MARK: - Sandbox View
struct SandboxView: View {
    
    @State private var showRiskBreakdown = false
    @State private var showAttachmentSheet = false
    @State private var selectedAssetName: String? = nil
    @State private var selectedURL: String? = nil
    @State private var localCorrection: Bool? = nil

    let email: MockEmail
    let onCorrection: ((Bool) -> Void)?

    var body: some View {
        
        ZStack {
            LinearGradient(
                colors: [.teal.opacity(0.5), .yellow.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    Text("Sandbox View")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)

                    // Email Header Card
                    SandboxCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SandboxCardHeader(icon: "envelope.fill", title: "Email Details")
                            SandboxDetailRow(label: "From", value: email.senderEmail, valueColor: email.effectiveIsPhishing ? .red : .black)
                            Divider()
                            SandboxDetailRow(label: "To", value: "your@email.com")
                            Divider()
                            SandboxDetailRow(label: "Subject", value: email.subject)
                            Divider()
                            HStack {
                                Text("Risk")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(email.effectiveIsPhishing ? "unsafe" : "safe")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(email.effectiveIsPhishing ? Color.red.opacity(0.8) : Color.green.opacity(0.8)))
                            }
                        }
                    }

                    // Body Card
                    SandboxCard {
                        VStack(alignment: .leading, spacing: 8) {
                            SandboxCardHeader(icon: "doc.text", title: "Body")
                            Text(email.body)
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(4)
                        }
                    }

                    // Links Card
                    if !email.links.isEmpty {
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "link", title: "Links")
                                ForEach(email.links, id: \.self) { link in
                                    HStack(spacing: 10) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                            .font(.subheadline)
                                        Text(link)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                        Spacer()
                                        Button {
                                            selectedURL = link
                                        } label: {
                                            Text("Open safely")
                                                .font(.caption.bold())
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Capsule().fill(Color.yellow.opacity(0.7)))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Attachments Card
                    if !email.attachments.isEmpty {
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "paperclip", title: "Attachments")
                                ForEach(email.attachments, id: \.self) { attachment in
                                    AttachmentRow(info: AttachmentInfo(filename: attachment)) { assetName in
                                        selectedAssetName = assetName
                                    }
                                    if attachment != email.attachments.last {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }

                    // User Correction Card
                    SandboxCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SandboxCardHeader(icon: "person.fill.checkmark", title: "Correct Classification")
                            
                            Text("Is the ML classification wrong? Let us know to improve the model.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                // Mark as Safe button
                                Button {
                                    localCorrection = false
                                    onCorrection?(false)
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: localCorrection == false ? "checkmark.circle.fill" : "checkmark.circle")
                                        Text("Mark as Safe")
                                            .font(.subheadline.bold())
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(localCorrection == false ? Color.green : Color.green.opacity(0.4))
                                    )
                                }
                                
                                // Mark as Unsafe button
                                Button {
                                    localCorrection = true
                                    onCorrection?(true)
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: localCorrection == true ? "xmark.circle.fill" : "xmark.circle")
                                        Text("Mark as Unsafe")
                                            .font(.subheadline.bold())
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(localCorrection == true ? Color.red : Color.red.opacity(0.4))
                                    )
                                }
                            }
                            
                            if localCorrection != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.teal)
                                    Text("Correction saved — will be used in next retrain")
                                        .font(.caption)
                                        .foregroundColor(.teal)
                                }
                            }
                        }
                    }
                    
                    // Risk Breakdown Button
                    Button {
                        showRiskBreakdown = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("View Risk Breakdown")
                                .font(.subheadline.bold())
                            Image(systemName: "paperplane")
                                .font(.subheadline)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.7))
                        )
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showRiskBreakdown) {
            RiskBreakdownSheet(email: email)
        }
        .sheet(item: $selectedURL) { url in
            SandboxWebSheet(urlString: url)
        }
        .sheet(item: $selectedAssetName) { name in
            AttachmentPreviewSheet(assetName: name)
        }
        .onAppear {
            localCorrection = email.userCorrection
        }
    }
}

// MARK: - Reusable Card
struct SandboxCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading) {
            content
                .padding(14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.55))
        )
    }
}

// MARK: - Card Header
struct SandboxCardHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.teal)
                .font(.subheadline)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding(.bottom, 2)
    }
}

// MARK: - Detail Row
struct SandboxDetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .black

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}



extension String: @retroactive Identifiable {
    public var id: String { self }
}
