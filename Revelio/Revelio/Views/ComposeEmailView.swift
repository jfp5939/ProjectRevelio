//
//  ComposeEmailView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI

struct ComposeEmailView: View {
    @State private var toField: String = ""
    @State private var ccField: String = ""
    @State private var bccField: String = ""
    @State private var subjectField: String = ""
    @State private var bodyField: String = ""
    @State private var showRiskBreakdown: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Image(systemName: "j.circle.fill")
                    .imageScale(.large)
                    .font(Font.largeTitle.bold())
                    .foregroundColor(.gray)

                VStack(alignment: .leading) {
                    Text("New Message")
                        .font(Font.title2.bold())
                        .foregroundColor(.black)
                    Text("your@email.com")
                        .font(Font.title3)
                        .foregroundColor(.black)
                }

                Spacer()
            }
            .padding()

            Divider()

            // Typeable Fields
            ScrollView {
                VStack(spacing: 0) {
                    ComposeFieldRow(label: "To:", text: $toField)
                    Divider()
                    ComposeFieldRow(label: "Cc:", text: $ccField)
                    Divider()
                    ComposeFieldRow(label: "Bcc:", text: $bccField)
                    Divider()
                    ComposeFieldRow(label: "Subject:", text: $subjectField)
                    Divider()

                    // Body — multiline
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Body:")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.top, 10)
                        TextEditor(text: $bodyField)
                            .frame(minHeight: 200)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                }
            }

            Divider()

            // Bottom Bar
            HStack(spacing: 12) {
                // Risk Breakdown button
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
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.6))
                    )
                }

                Spacer()

                // Send button
                Button {
                    // send action — wire up later
                } label: {
                    HStack(spacing: 6) {
                        Text("Send")
                            .font(.subheadline.bold())
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.teal)
                    )
                }
            }
            .padding()
        }
        .sheet(isPresented: $showRiskBreakdown) {
            RiskBreakdownSheet()
        }
    }
}

// MARK: - Single field row
struct ComposeFieldRow: View {
    let label: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)
            TextField("", text: $text)
                .foregroundColor(.black)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

#Preview {
    ComposeEmailView()
}
