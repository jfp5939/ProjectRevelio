//
//  EmaildetailView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//
import SwiftUI

struct EmailDetailView: View {
    let email: MockEmail
    let onCorrection: ((Bool) -> Void)?
    @State private var showRiskBreakdown = false
    @State private var selectedAssetName: String? = nil

    var accentColor: Color { email.effectiveIsPhishing ? .red : .green }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.teal.opacity(0.5), .yellow.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    // Sender Header Card
                    SandboxCard {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(accentColor.opacity(0.2))
                                    .frame(width: 52, height: 52)
                                Text(email.senderInitial)
                                    .font(.title2.bold())
                                    .foregroundColor(accentColor)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(email.senderName)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text(email.senderEmail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(email.time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(email.effectiveIsPhishing ? "unsafe" : "safe")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(accentColor.opacity(0.8)))
                        }
                    }

                    // Subject Card
                    SandboxCard {
                        VStack(alignment: .leading, spacing: 6) {
                            SandboxCardHeader(icon: "envelope.open", title: "Subject")
                            Text(email.subject)
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.85))
                        }
                    }

                    // Body Card
                    SandboxCard {
                        VStack(alignment: .leading, spacing: 8) {
                            SandboxCardHeader(icon: "doc.text", title: "Body")
                            Text(email.body)
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(5)
                        }
                    }

                    // Links Card — interactive, opens in Safari
                    if !email.links.isEmpty {
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "link", title: "Links")

                                if email.effectiveIsPhishing {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        Text("These links may be dangerous. Open in Sandbox for safe inspection.")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.bottom, 2)
                                }

                                ForEach(email.links, id: \.self) { link in
                                    HStack(spacing: 8) {
                                        Image(systemName: "link.circle")
                                            .font(.caption)
                                            .foregroundColor(accentColor)
                                        if let url = URL(string: link) {
                                            Link(link, destination: url)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                        } else {
                                            Text(link)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                        }
                                    }
                                    if link != email.links.last {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }

                    // Attachments Card — interactive, preview available
                    if !email.attachments.isEmpty {
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "paperclip", title: "Attachments")

                                if email.effectiveIsPhishing {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        Text("Some attachments may be dangerous. Open in Sandbox to inspect safely.")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.bottom, 2)
                                }

                                ForEach(email.attachments, id: \.self) { attachment in
                                    let info = AttachmentInfo(filename: attachment)
                                    HStack(spacing: 10) {
                                        Image(systemName: info.icon)
                                            .foregroundColor(info.isBlocked ? .red : .teal)
                                            .font(.subheadline)
                                            .frame(width: 24)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(attachment)
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                            Text(info.fileType)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        // Always allow open in detail view
                                        Button {
                                            selectedAssetName = info.assetName
                                            //showAttachmentSheet = true
                                        } label: {
                                            Text("Open")
                                                .font(.caption.bold())
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Capsule().fill(accentColor.opacity(0.25)))
                                        }
                                    }
                                    if attachment != email.attachments.last {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button {
                            showRiskBreakdown = true
                        } label: {
                            HStack(spacing: 6) {
                                Text("Risk Breakdown")
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

                        NavigationLink(destination: SandboxView(email: email, onCorrection: onCorrection)) {
                            HStack(spacing: 6) {
                                Text("Sandbox")
                                    .font(.subheadline.bold())
                                Image(systemName: "lock.square")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accentColor.opacity(0.8))
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle(email.senderName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRiskBreakdown) {
            RiskBreakdownSheet(email: email)
        }
        .sheet(item: $selectedAssetName) { name in
            AttachmentPreviewSheet(assetName: name)
        }
    }
}

