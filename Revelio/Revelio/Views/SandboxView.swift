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
        // Disable JS to reduce risk from malicious pages
        config.preferences.javaScriptEnabled = false
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
                // Warning Banner
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

// MARK: - Sandbox View
struct SandboxView: View {
    @State private var showRiskBreakdown = false
    @State private var showWebSheet = false
    @State private var selectedURL: String = ""

    let email: MockEmail
    //let linkURL = "http://paypa1-verify.com/login"

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.teal.opacity(0.5), .yellow.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    // Title
                    Text("Sandbox View")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)

                    // Email Header Card
                    SandboxCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SandboxCardHeader(icon: "envelope.fill", title: "Email Details")

                            SandboxDetailRow(label: "From", value: email.senderEmail, valueColor: email.isPhishing ? .red : .black)
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
                                Text(email.isPhishing ? "unsafe" : "safe")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(email.isPhishing ? Color.red.opacity(0.8) : Color.green.opacity(0.8)))
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

                    if !email.links.isEmpty {
                        // Links Card
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "link", title: "Links")
                                
                                ForEach(email.links, id: \.self){ link in
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
                                            showWebSheet = true
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

                    if !email.attachments.isEmpty{
                        // Attachments Card
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "paperclip", title: "Attachments")
                                
                                ForEach(email.attachments, id: \.self){ attachment in
                                    HStack(spacing: 10) {
                                        Image(systemName: "doc.fill")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                        
                                        Text(attachment)
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Text(email.isPhishing ? "blocked" : "unblocked")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(email.isPhishing ? Color.red.opacity(0.8) : Color.green.opacity(0.8)))
                                    }
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
        .sheet(isPresented: $showWebSheet) {
            SandboxWebSheet(urlString: selectedURL)
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



#Preview {
    SandboxView(email: MockEmail.samples[1])
}
