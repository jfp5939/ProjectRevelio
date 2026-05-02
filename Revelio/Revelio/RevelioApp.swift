//
//  RevelioApp.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI

@main
struct RevelioApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
//                .task {
//                        let loaded = await Task.detached(priority: .userInitiated) {
//                            EmailLoader.loadEmails()
//                        }.value
//                        if !loaded.isEmpty {
//                            emails = loaded
//                        }
//                    }
        }
    }
}
