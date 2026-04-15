//
//  SideBar.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

//import SwiftUI
//
//struct SideBarView: View {
//    var body: some View {
//        ZStack{
//            InboxView()
//            VStack {
//                HStack{
//                    Image(systemName: "line.3.horizontal")
//                        .imageScale(.large)
//                    //.foregroundStyle(.tint)
//                    Spacer()
//                }
//                Text("")
//                Text("")
//                Text("")
//                Text("")
//                HStack{
//                    Image(systemName: "tray.fill")
//                    Text("Inbox")
//                    Spacer()
//                }
//                Text("")
//                HStack{
//                    Image(systemName: "chart.pie.fill")
//                    Text("Dashboard")
//                    Spacer()
//                }
//                Text("")
//                HStack{
//                    Image(systemName: "gear")
//                    Text("Settings")
//                    Spacer()
//                }
//                Spacer()
//            }
//            .padding()
//            .background(
//                Rectangle()
//                    .fill(Color.white)
//                    .frame(width: 250, height: 1000)
//                    .padding(-200)
//            )
//        }
//    }
//}

import SwiftUI
 
struct SideBarView: View {
    @Binding var currentTab: AppTab
    @Binding var showSidebar: Bool
 
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                
                // Hamburger to close
                Button {
                    withAnimation(.easeInOut) {
                        showSidebar = false
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .imageScale(.large)
                        .foregroundColor(.black)
                        .padding(.bottom, 32)
                }
                
                // Nav items
                SideBarItem(icon: "tray.fill", label: "Inbox", isActive: currentTab == .inbox) {
                    currentTab = .inbox
                    withAnimation(.easeInOut) { showSidebar = false }
                }
                
                SideBarItem(icon: "chart.pie.fill", label: "Dashboard", isActive: currentTab == .dashboard) {
                    currentTab = .dashboard
                    withAnimation(.easeInOut) { showSidebar = false }
                }
                
                SideBarItem(icon: "gear", label: "Settings", isActive: currentTab == .settings) {
                    currentTab = .settings
                    withAnimation(.easeInOut) { showSidebar = false }
                }
                
                Spacer()
            }
            .padding(24)
            .frame(width: 220)
            //.frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 4, y: 0)
            )
            .padding(.top, 60)   // push down from top safe area
            .padding(.leading, 0)
        }
    }
}
 
// MARK: - Sidebar Row
struct SideBarItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
 
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 16, weight: isActive ? .semibold : .regular))
                Spacer()
            }
            .foregroundColor(isActive ? .teal : .black)
            .padding(.vertical, 14)
        }
        Divider()
    }
}

//#Preview {
//    SideBarView()
//}
