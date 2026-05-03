//
//  SentView.swift
//  Revelio
//
//  Created by Jiya Patel on 5/1/26.
//

import SwiftUI

struct SentView: View {
    @Binding var showSidebar: Bool
    @Binding var sentEmails: [MockEmail]

    @State private var searchQuery: String = ""
    @State private var showSearch: Bool = false
    @FocusState private var searchFocused: Bool

    var filteredSentEmails: [MockEmail] {
        guard !searchQuery.isEmpty else { return sentEmails.reversed() }
        let q = searchQuery.lowercased()
        return sentEmails.reversed().filter {
            $0.senderEmail.lowercased().contains(q) ||
            $0.subject.lowercased().contains(q) ||
            $0.body.lowercased().contains(q)
        }
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
                    VStack(spacing: 0) {

                        // Top Bar
                        HStack {
                            Button {
                                withAnimation(.easeInOut) { showSidebar = true }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            Text("Sent")
                                .font(.largeTitle.bold())

                            Spacer()

                            // Search toggle
                            Button {
                                withAnimation(.easeInOut) {
                                    showSearch.toggle()
                                    if showSearch {
                                        searchFocused = true
                                    } else {
                                        searchQuery = ""
                                        searchFocused = false
                                    }
                                }
                            } label: {
                                Image(systemName: showSearch ? "xmark.circle.fill" : "magnifyingglass")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()

                        // Search bar
                        if showSearch {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search by recipient, subject, or body", text: $searchQuery)
                                    .focused($searchFocused)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                if !searchQuery.isEmpty {
                                    Button {
                                        searchQuery = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.6)))
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        Spacer().frame(height: 12)

                        if filteredSentEmails.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: searchQuery.isEmpty ? "paperplane" : "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text(searchQuery.isEmpty ? "No sent emails yet" : "No emails found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(filteredSentEmails) { email in
                                NavigationLink(destination: EmailDetailView(email: email, onCorrection: nil)) {
                                    SentEmailRowView(email: email)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)

                                Spacer().frame(height: 12)
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Sent Email Row View
struct SentEmailRowView: View {
    let email: MockEmail
    @State private var showRiskBreakdown: Bool = false

    var accentColor: Color { email.effectiveIsPhishing ? .red : .green }
    var label: String { email.effectiveIsPhishing ? "unsafe" : "safe" }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(accentColor.opacity(0.25))
                .frame(maxWidth: .infinity, minHeight: 130)

            VStack(alignment: .leading, spacing: 2) {
                // Risk label + time
                HStack {
                    Text(label)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(accentColor.opacity(0.5)))
                        .padding([.top, .leading], 8)

                    Spacer()

                    Text(email.time)
                        .font(.subheadline.bold())
                        .foregroundColor(.black)
                        .padding([.top, .trailing], 12)
                }

                HStack(spacing: 10) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.9))
                            .frame(width: 44, height: 44)
                        Text(email.senderInitial)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("To: \(email.senderEmail)")
                            .font(.subheadline.bold())
                            .foregroundColor(.black)
                        Text(email.subject)
                            .font(.footnote)
                            .foregroundColor(.black.opacity(0.8))
                        Text(email.body)
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.55))
                            .lineLimit(1)
                    }

                    Spacer()

                    // Risk breakdown only, no sandbox
                    Button {
                        showRiskBreakdown = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Capsule().fill(.yellow.opacity(0.9)))
                    }
                    .padding(.trailing, 8)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showRiskBreakdown) {
            RiskBreakdownSheet(email: email)
        }
    }
}
