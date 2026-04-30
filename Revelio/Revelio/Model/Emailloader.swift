//
//  Emailloader.swift
//  Revelio
//
//  Created by Jiya Patel on 4/15/26.
//

import Foundation
import CoreML
import NaturalLanguage

struct EmailLoader {

    // Parses sender string "Name <email@domain.com>" into (name, email, initial)
    static func parseSender(_ sender: String) -> (name: String, email: String, initial: String) {
        // Try to split "Name <email>" format
        if let openBracket = sender.firstIndex(of: "<"),
           let closeBracket = sender.firstIndex(of: ">") {
            let nameUntrimmed = String(sender[sender.startIndex..<openBracket]).trimmingCharacters(in: .whitespaces)
            let name = nameUntrimmed.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let email = String(sender[sender.index(after: openBracket)..<closeBracket]).trimmingCharacters(in: .whitespaces)
            let initial = String(name.prefix(1)).uppercased()
            return (name.isEmpty ? email : name, email, initial.isEmpty ? "?" : initial)
        }
        // No brackets — the whole string is just an email
        let initial = String(sender.prefix(1)).uppercased()
        return (sender, sender, initial.isEmpty ? "?" : initial)
    }

    // Classifies a single email's text using CoreML
    // Returns true if phishing (label "1"), false if benign (label "0")
    static func classify(subject: String, body: String) -> Bool {
        let text = subject + " " + body
        do {
            let model = try MyTextClassifier_1(configuration: MLModelConfiguration())
            let prediction = try model.prediction(text: text)
            return prediction.label == "1"
        } catch {
            print("Classification error: \(error)")
            // Default to phishing on error — safer for a security app
            return true
        }
    }

    // Loads emails.json from the app bundle and returns [MockEmail]
    static func loadEmails() -> [MockEmail] {
        guard let url = Bundle.main.url(forResource: "emails", withExtension: "json") else {
            print("emails.json not found in bundle")
            return []
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load emails.json data")
            return []
        }

        guard let rawEmails = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("Failed to parse emails.json")
            return []
        }

        return rawEmails.compactMap { dict -> MockEmail? in
            // Pull fields from JSON
            guard let senderRaw = dict["sender"] as? String,
                  let subject = dict["subject"] as? String,
                  let body = dict["body"] as? String else {
                return nil
            }

            let receiver = dict["receiver"] as? String ?? ""
            let date = dict["date"] as? String ?? ""

            // Parse urls — stored as 0 or 1 in dataset
            let hasUrls = (dict["urls"] as? Int ?? 0) == 1

            // Parse sender
            let (name, email, initial) = parseSender(senderRaw)

            // Classify using CoreML
            let isPhishing = classify(subject: subject, body: body)

            // Extract a simple time string from date if available
            let time: String = {
                let parts = date.components(separatedBy: " ")
                if parts.count >= 5 {
                    let day = parts[1]
                    let month = parts[2]
                    let timeParts = parts[4].components(separatedBy: ":")
                    if timeParts.count >= 2 {
                        return "\(day) \(month) \(timeParts[0]):\(timeParts[1])"
                    }
                }
                return "—"
            }()

            return MockEmail(
                senderName: name,
                senderEmail: email,
                senderInitial: initial,
                subject: subject,
                body: body,
                time: time,
                isPhishing: isPhishing,
                links: dict["links"] as? [String] ?? [],
                attachments: dict["attachments"] as? [String] ?? []
            )
        }
    }
}
