//
//  SettingsView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI
import CreateML
import CoreML

struct SettingsView: View {
    @Binding var showSidebar: Bool
    let emails: [MockEmail]
    let sentEmails: [MockEmail]

    // Model info stored persistently
    @AppStorage("modelVersion") private var modelVersion: Int = 1
    @AppStorage("trainingAccuracy") private var trainingAccuracy: String = "100.0%"
    @AppStorage("validationAccuracy") private var validationAccuracy: String = "100.0%"
    @AppStorage("trainingDataSize") private var trainingDataSize: String = "31,300 emails"

    @State private var isRetraining: Bool = false
    @State private var retrainMessage: String = ""
    @State private var retrainSuccess: Bool = false
    @State private var retrainError: Bool = false

    // Build training data from all emails + corrections
    var trainingData: [(text: String, label: String)] {
        var data: [(text: String, label: String)] = []
        let allEmails = emails + sentEmails
        for email in allEmails {
            let text = email.subject + " " + email.body
            // userCorrection overrides ML label for training
            let label = (email.userCorrection ?? email.isPhishing) ? "1" : "0"
            data.append((text: text, label: label))
        }
        return data
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.teal.opacity(0.5), .yellow.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Top Bar
                        HStack {
                            Button {
                                withAnimation(.easeInOut) {
                                    showSidebar = true
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("Settings")
                                .font(.largeTitle.bold())
                            Spacer()
                            Image(systemName: "line.3.horizontal")
                                .imageScale(.large)
                                .hidden()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // ML Model Controls
                        SettingsCard {
                            VStack(spacing: 16) {
                                SettingsCardHeader(icon: "brain", title: "ML Model Controls")

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Retrain Model")
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                            Text("Uses inbox, sent, and corrected emails")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(trainingData.count) emails available for training")
                                                .font(.caption)
                                                .foregroundColor(.teal)
                                        }
                                        Spacer()
                                    }

                                    if isRetraining {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                                .tint(.teal)
                                            Text(retrainMessage.isEmpty ? "Preparing training data..." : retrainMessage)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.top, 4)
                                    } else if retrainSuccess {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Model v\(modelVersion) trained successfully!")
                                                .font(.caption.bold())
                                                .foregroundColor(.green)
                                        }
                                        .padding(.top, 4)
                                    } else if retrainError {
                                        HStack(spacing: 6) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                            Text(retrainMessage)
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                        .padding(.top, 4)
                                    }

                                    Button {
                                        retrainModel()
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .font(.subheadline)
                                            Text(isRetraining ? "Retraining..." : "Retrain Now")
                                                .font(.subheadline.bold())
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(isRetraining ? Color.gray : Color.teal)
                                        )
                                    }
                                    .disabled(isRetraining || trainingData.isEmpty)
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Model Info
                        SettingsCard {
                            VStack(spacing: 12) {
                                SettingsCardHeader(icon: "cpu", title: "Model Info")

                                SettingsInfoRow(label: "Model Version", value: "\(modelVersion).0")
                                Divider()
                                SettingsInfoRow(label: "Training Accuracy", value: trainingAccuracy)
                                Divider()
                                SettingsInfoRow(label: "Validation Accuracy", value: validationAccuracy)
                                Divider()
                                SettingsInfoRow(label: "Training Data", value: trainingDataSize)
                            }
                        }
                        .padding(.horizontal)

                        // About
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SettingsCardHeader(icon: "info.circle", title: "About Revelio")

                                Text("Revelio is an intelligent email security app that uses on-device machine learning to protect users from phishing threats. Powered by a CoreML model trained on real-world phishing data, Revelio classifies every email in your inbox as safe or suspicious and explains exactly why, surfacing the specific signals that make an email dangerous, in plain language anyone can understand.")
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.75))
                                    .lineSpacing(4)

                                Text("Unlike traditional spam filters that silently discard emails without explanation, Revelio puts the user in control: open emails in a secure sandbox, inspect links safely, and track threat trends over time through an interactive dashboard. All classification happens on-device — no email data ever leaves your phone.")
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.75))
                                    .lineSpacing(4)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Retrain
    func retrainModel() {
        guard !trainingData.isEmpty else {
            retrainError = true
            retrainMessage = "No training data available."
            return
        }

        isRetraining = true
        retrainSuccess = false
        retrainError = false
        retrainMessage = "Preparing training data..."

        Task.detached(priority: .userInitiated) {
            do {
                // Build MLDataTable
                await MainActor.run { retrainMessage = "Building training table..." }

                let texts = trainingData.map { $0.text }
                let labels = trainingData.map { $0.label }

                let table = try MLDataTable(dictionary: [
                    "text": texts,
                    "label": labels
                ])

                await MainActor.run { retrainMessage = "Training model..." }

                // Split 80/20
                let (trainTable, testTable) = table.randomSplit(by: 0.8, seed: 42)

                // Train
                let classifier = try MLTextClassifier(
                    trainingData: trainTable,
                    textColumn: "text",
                    labelColumn: "label"
                )

                await MainActor.run { retrainMessage = "Evaluating model..." }

                // Evaluate
                let trainMetrics = classifier.trainingMetrics
                let validMetrics = classifier.validationMetrics
                let trainAcc = String(format: "%.1f%%", (1.0 - trainMetrics.classificationError) * 100)
                let validAcc = String(format: "%.1f%%", (1.0 - validMetrics.classificationError) * 100)

                await MainActor.run { retrainMessage = "Saving model..." }

                // Save to documents directory
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let newVersion = modelVersion + 1
                let modelURL = documentsURL.appendingPathComponent("MyTextClassifier_v\(newVersion).mlmodel")

                try classifier.write(to: modelURL)

                // Compile the model
                let compiledURL = try MLModel.compileModel(at: modelURL)

                // Move compiled model to permanent location
                let permanentURL = documentsURL.appendingPathComponent("MyTextClassifier_v\(newVersion).mlmodelc")
                if FileManager.default.fileExists(atPath: permanentURL.path) {
                    try FileManager.default.removeItem(at: permanentURL)
                }
                try FileManager.default.moveItem(at: compiledURL, to: permanentURL)

                // Update stored model path and info
                UserDefaults.standard.set(permanentURL.path, forKey: "customModelPath")

                await MainActor.run {
                    modelVersion = newVersion
                    trainingAccuracy = trainAcc
                    validationAccuracy = validAcc
                    trainingDataSize = "\(trainingData.count) emails"
                    isRetraining = false
                    retrainSuccess = true
                    retrainMessage = ""
                }

            } catch {
                await MainActor.run {
                    isRetraining = false
                    retrainError = true
                    retrainMessage = "Retraining failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Reusable Card Container
struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.55))
        )
    }
}

// MARK: - Card Header
struct SettingsCardHeader: View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }
}

// MARK: - Info Row
struct SettingsInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.teal)
        }
    }
}

#Preview {
    SettingsView(
        showSidebar: .constant(false),
        emails: MockEmail.samples,
        sentEmails: []
    )
}
