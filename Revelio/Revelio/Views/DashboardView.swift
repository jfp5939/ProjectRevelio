//
//  DashboardView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI

struct DashboardView: View {
    @Binding var showSidebar: Bool

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

                            Text("Dashboard")
                                .font(.largeTitle.bold())

                            Spacer()

                            // Balances the hamburger so title stays centered
                            Image(systemName: "line.3.horizontal")
                                .imageScale(.large)
                                .hidden()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Pie Chart Section
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Phishing vs. Benign", icon: "chart.pie.fill")

                            // Placeholder — replace with SwiftCharts PieChart
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.5))
                                .frame(height: 200)
                                .overlay(
                                    VStack(spacing: 6) {
                                        Image(systemName: "chart.pie")
                                            .font(.system(size: 48))
                                            .foregroundColor(.teal.opacity(0.6))
                                        Text("Pie chart coming soon")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }
                        .padding(.horizontal)

                        // Stats Row
                        HStack(alignment: .top, spacing: 12) {
                            StatCard(
                                title: "Top Suspicious Domains",
                                icon: "globe",
                                items: ["go0g1e.com", "paypa1-verify.net", "secure-login.xyz"]
                            )
                            StatCard(
                                title: "Top Phishing Keywords",
                                icon: "exclamationmark.triangle",
                                items: ["urgent", "immediately", "verify now"]
                            )
                            StatCard(
                                title: "Blocked Actions",
                                icon: "shield.slash",
                                items: ["blocked link", "blocked attachment"]
                            )
                        }
                        .padding(.horizontal)

                        // Line Chart Section
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Risk Trend Over Time", icon: "chart.line.uptrend.xyaxis")

                            // Placeholder — replace with SwiftCharts LineChart
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.5))
                                .frame(height: 180)
                                .overlay(
                                    VStack(spacing: 6) {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .font(.system(size: 48))
                                            .foregroundColor(.teal.opacity(0.6))
                                        Text("Line chart coming soon")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
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

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.teal)
                .font(.subheadline)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let icon: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.teal)
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Text("\(index + 1). \(item)")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.5))
        )
    }
}

#Preview {
    DashboardView(showSidebar: .constant(false))
}
