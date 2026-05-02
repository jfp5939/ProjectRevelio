//
//  ContentView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI
 
enum AppTab {
    case inbox, sent, dashboard, settings
}
 
struct MainView: View {
    @State private var currentTab: AppTab = .inbox
    @State private var showSidebar: Bool = false
    @State private var sentEmails: [MockEmail] = []
    //let emails: [MockEmail]
    @State private var emails: [MockEmail] = []
    //@Binding var emails: [MockEmail]
    
    func loadInboxEmails() -> [MockEmail] {
        guard let data = UserDefaults.standard.data(forKey: "inboxEmails"),
              let decoded = try? JSONDecoder().decode([MockEmail].self, from: data) else {
            return []
        }
        return decoded
    }

    func saveInboxEmails(_ emails: [MockEmail]) {
        if let encoded = try? JSONEncoder().encode(emails) {
            UserDefaults.standard.set(encoded, forKey: "inboxEmails")
        }
    }
    
    func loadSentEmails() -> [MockEmail] {
        guard let data = UserDefaults.standard.data(forKey: "sentEmails"),
              let decoded = try? JSONDecoder().decode([MockEmail].self, from: data) else {
            return []
        }
        return decoded
    }

    func saveSentEmails(_ emails: [MockEmail]) {
        if let encoded = try? JSONEncoder().encode(emails) {
            UserDefaults.standard.set(encoded, forKey: "sentEmails")
        }
    }
    var body: some View {
        ZStack(alignment: .leading) {
 
            //showSidebar: $showSidebar
            // Main content — swaps based on active tab
            Group {
                switch currentTab {
                case .inbox:
                    InboxView(showSidebar: $showSidebar, emails: $emails, sentEmails: $sentEmails)
                case .sent:
                    SentView(showSidebar: $showSidebar, sentEmails: $sentEmails)
                case .dashboard:
                    DashboardView(showSidebar: $showSidebar, emails: emails)
                case .settings:
                    SettingsView(showSidebar: $showSidebar, emails: emails, sentEmails: sentEmails)
                }
            }
            
            // Sidebar overlay — only rendered when open
            if showSidebar {
                // Dim background tap to close
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showSidebar = false
                        }
                    }
 
                SideBarView(currentTab: $currentTab, showSidebar: $showSidebar)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showSidebar)
        .task {
            let saved = loadInboxEmails()
            if !saved.isEmpty {
                emails = saved
            } else {
                let loaded = await Task.detached(priority: .userInitiated) {
                    EmailLoader.loadEmails()
                }.value
                if !loaded.isEmpty {
                    emails = loaded
                    saveInboxEmails(loaded)
                }
            }
        }
        .onChange(of: emails) {
            saveInboxEmails(emails)
        }
        .onAppear {
            sentEmails = loadSentEmails()
        }
        .onChange(of: sentEmails) {
            saveSentEmails(sentEmails)
        }
    }
}
 

#Preview {
    //MainView()
}
