//
//  SettingsView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

//import SwiftUI
//
//struct SettingsView: View {
//    @State private var strictness: Double = 50.0
//    @State private var isEnabled = false
//    
//    var body: some View {
//        ZStack {
//            LinearGradient(colors: [Color(white: 1.0), Color(white: 0.8)],
//                           startPoint: .topLeading,
//                           endPoint: .bottomTrailing)
//                .ignoresSafeArea()
//            VStack(alignment: .leading) {
//                Text("                Settings")
//                    .font(Font.largeTitle.bold())
//                Divider()
//                HStack {
//                    Text("Strictness:")
//                    Slider(value: $strictness, in: 0...100)
//                }
//                Divider()
//                .frame(maxWidth: .infinity)
//                Toggle("Retrain Model:", isOn: $isEnabled)
//                Divider()
//                Text("Model Version: 1.0")
//                Divider()
//                Text("ML Model training accuracy: 94.2%")
//                Divider()
//                Text("ML Model validation accuracy: 92.7%")
//                Divider()
//                Text("About:")
//                    .font(Font.title.bold())
//                Text("Revelio is an intelligent email security app that uses on-device machine learning to protect users from phishing threats. Powered by a CoreML model trained on real-world phishing data, Revelio classifies every email in your inbox as safe or suspicious and explains exactly why, surfacing the specific signals that make an email dangerous, in plain language anyone can understand. Unlike traditional spam filters that silently discard emails without explanation, Revelio puts the user in control: open emails in a secure sandbox, inspect links safely, and track threat trends over time through an interactive dashboard. Revelio was built with privacy in mind, all classification happens on-device, and no email data ever leaves your phone.")
//                Spacer()
//            }
//            .padding()
//        }
//    }
//}

import SwiftUI

struct SettingsView: View {
    @Binding var showSidebar: Bool
    @State private var strictness: Double = 50.0
    @State private var isEnabled = false

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
                                        Text("Strictness")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text("\(Int(strictness))%")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.teal)
                                    }
                                    Slider(value: $strictness, in: 0...100, step: 1)
                                        .tint(.teal)
                                }

                                Divider()

                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Retrain Model")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                        Text("Use stored emails to fine-tune")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $isEnabled)
                                        .tint(.teal)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Model Info
                        SettingsCard {
                            VStack(spacing: 12) {
                                SettingsCardHeader(icon: "cpu", title: "Model Info")

                                SettingsInfoRow(label: "Model Version", value: "1.0")
                                Divider()
                                SettingsInfoRow(label: "Training Accuracy", value: "94.2%")
                                Divider()
                                SettingsInfoRow(label: "Validation Accuracy", value: "92.7%")
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
    SettingsView(showSidebar: .constant(false))
}
