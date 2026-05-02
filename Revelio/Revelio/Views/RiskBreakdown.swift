//
//  RiskBreakdown.swift
//  Revelio
//
//  Created by Jiya Patel on 4/17/26.
//

import SwiftUI
import Foundation

struct RiskSignal {
    let icon: String
    let label: String
    let detail: String
}

struct RiskAnalyzer {
    static func analyze(_ email: MockEmail) -> [RiskSignal] {
        var signals: [RiskSignal] = []

        let urgencyWords: [String] = ["urgent", "immediately", "suspend", "verify", "click now", "account", "password", "login", "confirm"]
        let executableExtensions = [".exe", ".sh", ".dmg", ".bat", ".js"]
        let domain = email.senderEmail.components(separatedBy: "@").last ?? ""
        let suspiciousDigits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

        if email.effectiveIsPhishing {
            // Urgency keywords
            for s in urgencyWords {
                if email.subject.lowercased().contains(s) || email.body.lowercased().contains(s) {
                    signals.append(RiskSignal(
                        icon: "exclamationmark.triangle.fill",
                        label: "Urgency keyword: \(s)",
                        detail: "Words like '\(s)' are common phishing signals used to pressure victims."
                    ))
                }
            }

            // Executable attachments
            for attachment in email.attachments {
                for ext in executableExtensions {
                    if attachment.lowercased().hasSuffix(ext) {
                        signals.append(RiskSignal(
                            icon: "paperclip",
                            label: "Executable attachment: \(attachment)",
                            detail: "Files with extension '\(ext)' are blocked — they may contain malware."
                        ))
                    }
                }
            }

            // Suspicious domain
            for digit in suspiciousDigits {
                if domain.contains(digit) {
                    signals.append(RiskSignal(
                        icon: "globe",
                        label: "Suspicious sender domain",
                        detail: "Numbers found in '\(domain)' — likely a misspelled domain mimicking a legitimate one."
                    ))
                    break
                }
            }

            // Links present
            if !email.links.isEmpty {
                signals.append(RiskSignal(
                    icon: "link",
                    label: "Suspicious link detected",
                    detail: "This email contains links. Open in sandbox to inspect them safely before clicking."
                ))
            }

            // Fallback if no signals were detected but still phishing
            if signals.isEmpty {
                signals.append(RiskSignal(
                    icon: "shield.lefthalf.filled",
                    label: "Flagged by ML model",
                    detail: "This email was classified as phishing by the on-device ML model based on its content patterns."
                ))
            }

        } else {
            // Safe email signals
            signals.append(RiskSignal(
                icon: "checkmark.shield.fill",
                label: "No threats detected",
                detail: "This email was classified as safe by the on-device ML model."
            ))
            if email.links.isEmpty {
                signals.append(RiskSignal(
                    icon: "link",
                    label: "No links",
                    detail: "No links found in this email."
                    
                ))
            }
            if email.attachments.isEmpty {
                signals.append(RiskSignal(
                    icon: "paperclip",
                    label: "No attachments",
                    detail: "No attachments found in this email."
                ))
            }
        }

        return signals
    }
}


// MARK: - Risk Breakdown Sheet
struct RiskBreakdownSheet: View {
    let email: MockEmail
    
    var signals: [RiskSignal] {
        RiskAnalyzer.analyze(email)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Risk Breakdown")
                .font(.largeTitle.bold())
                .padding(.top, 8)

            Divider()

            if signals.isEmpty {
                Text("No risk signals detected.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(signals, id: \.label) { signal in
                    RiskFactor(
                        icon: signal.icon,
                        label: signal.label,
                        detail: signal.detail,
                        isPhishing: email.effectiveIsPhishing
                    )
                }
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Risk Factor Row
struct RiskFactor: View {
    let icon: String
    let label: String
    let detail: String
    let isPhishing: Bool

    var accentColor: Color { isPhishing ? .red : .green }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.06))
        )
    }
}
