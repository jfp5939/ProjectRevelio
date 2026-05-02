//
//  InboxView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI

enum FilterOption {
    case all, safe, unsafe
}

struct InboxView: View {
    @Binding var showSidebar: Bool
    @State private var showCompose: Bool = false
    @State private var showFilter: Bool = false
    @State private var filterOption: FilterOption = .all
    @State private var searchQuery: String = ""
    @State private var showSearch: Bool = false
    @FocusState private var searchFocused: Bool
    //@State private var emails: [MockEmail] = []
    @Binding var emails: [MockEmail]
    @Binding var sentEmails: [MockEmail]
    // Swap MockEmail.samples for @Query when SwiftData is ready
    //let emails: [MockEmail] = MockEmail.samples

    var filteredEmails: [MockEmail] {
        emails.filter { email in
            // Apply filter option
            let matchesFilter: Bool
            switch filterOption {
            case .all:    matchesFilter = true
            case .safe:   matchesFilter = !email.effectiveIsPhishing
            case .unsafe: matchesFilter = email.effectiveIsPhishing
            }

            // Apply search query
            let matchesSearch: Bool
            if searchQuery.isEmpty {
                matchesSearch = true
            } else {
                let q = searchQuery.lowercased()
                matchesSearch =
                    email.senderName.lowercased().contains(q) ||
                    email.senderEmail.lowercased().contains(q) ||
                    email.subject.lowercased().contains(q) ||
                    email.body.lowercased().contains(q)
            }

            return matchesFilter && matchesSearch
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
                            HStack {
                                Button {
                                    withAnimation(.easeInOut) { showSidebar = true }
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .imageScale(.large)
                                        .foregroundColor(.black)
                                }

                                Button {
                                    showCompose = true
                                } label: {
                                    Image(systemName: "pencil.circle")
                                        .imageScale(.large)
                                        .foregroundColor(.black)
                                }
                            }

                            Spacer()
                            Text("Inbox")
                                .font(Font.largeTitle.bold())
                            Spacer()

                            HStack {
                                Button {
                                    showFilter = true
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .imageScale(.large)
                                        .foregroundColor(.black)
                                }

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
                        }
                        .padding()

                        // Search bar
                        if showSearch {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search by sender, subject, or body", text: $searchQuery)
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

                        // Email list
                        if filteredEmails.isEmpty {
//                            VStack(spacing: 8) {
//                                Image(systemName: "tray")
//                                    .font(.system(size: 40))
//                                    .foregroundColor(.secondary)
//                                Text("No emails found")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                            .padding(.top, 60)
                            ProgressView("Loading emails...")
                                    .padding(.top, 60)
                        } else {
                            ForEach(filteredEmails) { email in
                                NavigationLink(destination: EmailDetailView(
                                    email: email,
                                    onCorrection: { correction in
                                        if let index = emails.firstIndex(where: { $0.id == email.id }) {
                                            emails[index].userCorrection = correction
                                        }
                                    }
                                )) {
                                    EmailRowView(email: email)
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
            .sheet(isPresented: $showCompose) {
                ComposeEmailView(sentEmails: $sentEmails)
            }
            .confirmationDialog("Filter Emails", isPresented: $showFilter, titleVisibility: .visible) {
                Button("All") { filterOption = .all }
                Button("Safe") { filterOption = .safe }
                Button("Unsafe") { filterOption = .unsafe }
                Button("Cancel", role: .cancel) {}
            }
//            .onAppear {
//                Task {
//                    let loaded = await Task.detached(priority: .userInitiated) {
//                        EmailLoader.loadEmails()
//                    }.value
//                    
//                    let allEmails = loaded.isEmpty ? MockEmail.samples : loaded
//                    
//                    // Guarantee at least 1 safe and 1 unsafe
//                    let phishing = allEmails.filter { $0.isPhishing }.shuffled()
//                    let benign = allEmails.filter { !$0.isPhishing }.shuffled()
//                    
//                    // Take up to 10 from each, then mix and shuffle
//                    let combined = Array(phishing.prefix(10) + benign.prefix(10))
//                    emails = combined.shuffled().prefix(20).map { $0 }
//                }
//            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Email Row View
struct EmailRowView: View {
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
                        Text(email.senderName)
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

                    VStack(spacing: 8) {
                        // Info -> RiskBreakdownSheet
                        Button {
                            showRiskBreakdown = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Capsule().fill(.yellow.opacity(0.9)))
                        }

                        // Open in Sandbox
                        NavigationLink(destination: SandboxView(email: email, onCorrection: nil)) {
                            Image(systemName: "lock.square")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Capsule().fill(accentColor.opacity(0.9)))
                        }
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
