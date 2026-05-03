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

    // MARK: - Custom Model Path
    // After retraining, the new model is saved to documents directory
    // This checks if a retrained model exists and returns its URL
    @MainActor
    static var customModelURL: URL? {
        guard let path = UserDefaults.standard.string(forKey: "customModelPath") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return url
    }

    // MARK: - Sender Parser
    // Parses sender string "Name <email@domain.com>" into (name, email, initial)
    static func parseSender(_ sender: String) -> (name: String, email: String, initial: String) {
        if let openBracket = sender.firstIndex(of: "<"),
           let closeBracket = sender.firstIndex(of: ">") {
            let nameUntrimmed = String(sender[sender.startIndex..<openBracket]).trimmingCharacters(in: .whitespaces)
            let name = nameUntrimmed.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let email = String(sender[sender.index(after: openBracket)..<closeBracket]).trimmingCharacters(in: .whitespaces)
            let initial = String(name.prefix(1)).uppercased()
            return (name.isEmpty ? email : name, email, initial.isEmpty ? "?" : initial)
        }
        let initial = String(sender.prefix(1)).uppercased()
        return (sender, sender, initial.isEmpty ? "?" : initial)
    }

    // MARK: - Classifier
    // First tries custom retrained model if available
    // Falls back to bundled MyTextClassifier_1 if not
    @MainActor
    static func classify(subject: String, body: String) -> Bool {
        let text = subject + " " + body
        do {
            // Try custom retrained model first
            if let customURL = customModelURL {
                let compiledModel = try MLModel(contentsOf: customURL)
                let input = try MLDictionaryFeatureProvider(
                    dictionary: ["text": text as NSString]
                )
                let output = try compiledModel.prediction(from: input)
                if let label = output.featureValue(for: "label")?.stringValue {
                    return label == "1"
                }
            }

            // Fall back to bundled model
            let model = try MyTextClassifier_1(configuration: MLModelConfiguration())
            let prediction = try model.prediction(text: text)
            return prediction.label == "1"

        } catch {
            print("Classification error: \(error)")
            return true
        }
    }

    // MARK: - Email Loader
    // Loads emails.json from the app bundle and returns [MockEmail]
    @MainActor
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
            guard let senderRaw = dict["sender"] as? String,
                  let subject = dict["subject"] as? String,
                  let body = dict["body"] as? String else {
                return nil
            }

            let date = dict["date"] as? String ?? ""
            let (name, email, initial) = parseSender(senderRaw)
            let isPhishing = classify(subject: subject, body: body)

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
                attachments: dict["attachments"] as? [String] ?? [],
                userCorrection: nil
            )
        }
    }
}
