//
//  MockEmail.swift
//  Revelio
//
//  Created by Jiya Patel on 4/14/26.
//

import Foundation

struct MockEmail: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let senderName: String
    let senderEmail: String
    let senderInitial: String
    let subject: String
    let body: String
    let time: String
    let isPhishing: Bool
    let links: [String]
    let attachments: [String]
    var userCorrection: Bool?
    var effectiveIsPhishing: Bool {
        return userCorrection ?? isPhishing
    }
}

extension MockEmail {
    // Loaded from emails.json + classified by CoreML
    // Falls back to hardcoded samples if loading fails
    static let loaded: [MockEmail] = {
        let emails = EmailLoader.loadEmails()
        return emails.isEmpty ? MockEmail.samples : emails
    }()

    // Hardcoded fallback samples
    static let samples: [MockEmail] = [
        MockEmail(
            senderName: "PayPal Support",
            senderEmail: "support@paypa1-verify.com",
            senderInitial: "P",
            subject: "Urgent: Verify your account now",
            body: "Dear Customer, your account has been suspended. Click the link below to verify your identity immediately or your account will be closed.",
            time: "18:10",
            isPhishing: true,
            links: ["http://paypa1-verify.com/login"],
            attachments: ["invoice.exe"],
            userCorrection: nil
        ),
        MockEmail(
            senderName: "Jane Smith",
            senderEmail: "jane.smith@gmail.com",
            senderInitial: "J",
            subject: "Team lunch on Friday?",
            body: "Hey! Just wanted to check if you're free for team lunch this Friday at noon. Let me know if that works for you.",
            time: "11:11",
            isPhishing: false,
            links: [],
            attachments: [],
            userCorrection: nil
        )
    ]
}
