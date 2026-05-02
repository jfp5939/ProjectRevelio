//
//  DashboardView.swift
//  Revelio
//
//  Created by Jiya Patel on 4/6/26.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @Binding var showSidebar: Bool
    let emails: [MockEmail]

    // MARK: - Computed Stats

    var phishingCount: Int { emails.filter { $0.isPhishing }.count }
    var benignCount: Int { emails.filter { !$0.isPhishing }.count }

    var topDomains: [String] {
        let domains = emails
            .filter { $0.isPhishing }
            .compactMap { $0.senderEmail.components(separatedBy: "@").last }
        let counts = Dictionary(domains.map { ($0, 1) }, uniquingKeysWith: +)
        return counts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }

    var topKeywords: [String] {
        let keywords = ["urgent", "verify", "suspended", "immediately", "account", "password", "login", "confirm"]
        var counts: [String: Int] = [:]
        for email in emails.filter({ $0.isPhishing }) {
            let text = (email.subject + " " + email.body).lowercased()
            for keyword in keywords {
                if text.contains(keyword) {
                    counts[keyword, default: 0] += 1
                }
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }

    var blockedActions: [String] {
        let blockedExtensions = [".exe", ".sh", ".dmg", ".bat", ".js"]
        let blockedAttachments = emails.flatMap { $0.attachments }.filter { attachment in
            blockedExtensions.contains{ attachment.lowercased().hasSuffix($0) }
        }.count
        let suspiciousLinks = emails.filter { $0.isPhishing && !$0.links.isEmpty }.count
        return [
            "\(suspiciousLinks) suspicious link(s)",
            "\(blockedAttachments) blocked attachment(s)"
        ]
    }

    // Group emails by day for line chart
    var riskByDay: [(day: String, phishing: Int, benign: Int)] {
        var grouped: [String: (phishing: Int, benign: Int)] = [:]
        for email in emails {
            let parts = email.time.components(separatedBy: " ")
            // time format is "08 Aug 18:45" — day is parts[0], month is parts[1]
            let day = parts.count >= 2 ? "\(parts[0]) \(parts[1])" : email.time
            var current = grouped[day] ?? (phishing: 0, benign: 0)
            if email.effectiveIsPhishing {
                current.phishing += 1
            } else {
                current.benign += 1
            }
            grouped[day] = current
        }
        return grouped.sorted { $0.key < $1.key }.map { (day: $0.key, phishing: $0.value.phishing, benign: $0.value.benign) }
    }

    // Pie chart data
    var pieData: [(label: String, count: Int, color: Color)] {
        [
            ("Phishing", phishingCount, .red),
            ("Benign", benignCount, .green)
        ]
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
                                withAnimation(.easeInOut) { showSidebar = true }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("Dashboard")
                                .font(.largeTitle.bold())
                            Spacer()
                            Image(systemName: "line.3.horizontal")
                                .imageScale(.large)
                                .hidden()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Pie Chart
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Phishing vs. Benign", icon: "chart.pie.fill")

                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.5))
                                .frame(height: 220)
                                .overlay {
                                    if emails.isEmpty {
                                        Text("Loading...")
                                            .foregroundColor(.secondary)
                                    } else {
                                        HStack(spacing: 24) {
                                            Chart(pieData, id: \.label) { item in
                                                SectorMark(
                                                    angle: .value("Count", item.count),
                                                    innerRadius: .ratio(0.5),
                                                    angularInset: 2
                                                )
                                                .foregroundStyle(item.color.opacity(0.8))
                                            }
                                            .frame(width: 140, height: 140)

                                            VStack(alignment: .leading, spacing: 10) {
                                                ForEach(pieData, id: \.label) { item in
                                                    HStack(spacing: 8) {
                                                        Circle()
                                                            .fill(item.color.opacity(0.8))
                                                            .frame(width: 10, height: 10)
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(item.label)
                                                                .font(.caption.bold())
                                                                .foregroundColor(.black)
                                                            Text("\(item.count) emails")
                                                                .font(.caption2)
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                    }
                                }
                        }
                        .padding(.horizontal)

                        // Stats Row
                        HStack(alignment: .top, spacing: 12) {
                            StatCard(
                                title: "Top Suspicious Domains",
                                icon: "globe",
                                items: topDomains.isEmpty ? ["No data"] : topDomains
                            )
                            StatCard(
                                title: "Top Phishing Keywords",
                                icon: "exclamationmark.triangle",
                                items: topKeywords.isEmpty ? ["No data"] : topKeywords
                            )
                            StatCard(
                                title: "Blocked Actions",
                                icon: "shield.slash",
                                items: blockedActions
                            )
                        }
                        .padding(.horizontal)

                        // Line Chart
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Risk Trend Over Time", icon: "chart.line.uptrend.xyaxis")

                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.5))
                                .frame(height: 200)
                                .overlay {
                                    if riskByDay.isEmpty {
                                        Text("Loading...")
                                            .foregroundColor(.secondary)
                                    } else {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Chart {
                                                ForEach(riskByDay, id: \.day) { entry in
                                                    LineMark(
                                                        x: .value("Day", entry.day),
                                                        y: .value("Count", entry.phishing)
                                                    )
                                                    .foregroundStyle(by: .value("Type", "Phishing"))
                                                    .symbol(.circle)

                                                    LineMark(
                                                        x: .value("Day", entry.day),
                                                        y: .value("Count", entry.benign)
                                                    )
                                                    .foregroundStyle(by: .value("Type", "Benign"))
                                                    .symbol(.circle)
                                                }
                                            }
                                            .chartForegroundStyleScale([
                                                "Phishing": Color.red,
                                                "Benign": Color.green
                                            ])
                                            .chartYScale(domain: 0...10)
                                            .chartXAxis {
                                                AxisMarks(values: .automatic) { _ in
                                                    AxisValueLabel()
                                                        .font(.caption2)
                                                }
                                            }
                                            .chartYAxis {
                                                AxisMarks(values: .automatic) { _ in
                                                    AxisGridLine()
                                                    AxisValueLabel()
                                                        .font(.caption2)
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)

//                                            // Legend
//                                            HStack(spacing: 16) {
//                                                HStack(spacing: 4) {
//                                                    Circle().fill(.red).frame(width: 8, height: 8)
//                                                    Text("Phishing").font(.caption2).foregroundColor(.secondary)
//                                                }
//                                                HStack(spacing: 4) {
//                                                    Circle().fill(.green).frame(width: 8, height: 8)
//                                                    Text("Benign").font(.caption2).foregroundColor(.secondary)
//                                                }
//                                            }
//                                            .padding(.leading, 12)
//                                            .padding(.bottom, 8)
                                        }
                                    }
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

