//
//  ContentView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI
 
enum AppTab {
    case inbox, dashboard, settings
}
 
struct MainView: View {
    @State private var currentTab: AppTab = .inbox
    @State private var showSidebar: Bool = false
    //let emails: [MockEmail]
    @Binding var emails: [MockEmail]
    var body: some View {
        ZStack(alignment: .leading) {
 
            //showSidebar: $showSidebar
            // Main content — swaps based on active tab
            Group {
                switch currentTab {
                case .inbox:
                    InboxView(showSidebar: $showSidebar, emails: $emails)
                case .dashboard:
                    DashboardView(showSidebar: $showSidebar, emails: $emails)
                case .settings:
                    SettingsView(showSidebar: $showSidebar)
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
    }
}
 

#Preview {
    //MainView()
}
