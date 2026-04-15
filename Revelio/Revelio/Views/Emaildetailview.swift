//
//  Emaildetailview.swift
//  Revelio
//
//  Created by Jiya Patel on 4/14/26.
//

import SwiftUI

struct EmailDetailView: View {
    let email: MockEmail
    @State private var showRiskBreakdown = false

    var accentColor: Color { email.isPhishing ? .red : .green }

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
                            // Avatar
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

                            // Risk badge
                            Text(email.isPhishing ? "unsafe" : "safe")
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

                    // Body Card — plain reading, no interaction
                    SandboxCard {
                        VStack(alignment: .leading, spacing: 8) {
                            SandboxCardHeader(icon: "doc.text", title: "Body")
                            Text(email.body)
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(5)
                        }
                    }

                    // Links Card — displayed as plain unclickable text
                    if !email.links.isEmpty {
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "link", title: "Links")
                                Text("Open in Sandbox to interact with links safely.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 2)
                                ForEach(email.links, id: \.self) { link in
                                    HStack(spacing: 8) {
                                        Image(systemName: "minus.circle")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(link)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    if link != email.links.last {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }

                    // Attachments Card — listed by name only, no interaction
                    if !email.attachments.isEmpty {
                        SandboxCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SandboxCardHeader(icon: "paperclip", title: "Attachments")
                                Text("Open in Sandbox to inspect attachments safely.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 2)
                                ForEach(email.attachments, id: \.self) { attachment in
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(attachment)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                        // Risk Breakdown
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

                        // Open in Sandbox
                        NavigationLink(destination: SandboxView()) {
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
            RiskBreakdownSheet()
        }
    }
}

#Preview {
    EmailDetailView(email: MockEmail.samples[0])
}
