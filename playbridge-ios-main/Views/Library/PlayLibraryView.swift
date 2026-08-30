//
//  PlayLibraryView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// "Play Library" — ebeveynin gerçekten oynadığı oyunların defteri.
///
/// Buraya sadece "Put the phone down & play" denen aktiviteler giriyor.
/// Bakılıp geçilen, "Try a different idea" ile atılan öneriler burada yok.
struct PlayLibraryView: View {
    @State private var viewModel = PlayLibraryViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if viewModel.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationTitle("Play Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationDestination(for: PlayedActivity.self) { entry in
                PlayedActivityDetailView(entry: entry, viewModel: viewModel)
            }
        }
        .onAppear { viewModel.load() }
    }

    // MARK: - Dolu hâl

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(viewModel.summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                FlowLayout(spacing: 8) {
                    ForEach(LibraryFilter.allCases) { option in
                        SelectableChip(
                            title: option.title,
                            isSelected: viewModel.filter == option
                        ) {
                            viewModel.filter = option
                        }
                    }
                }

                if viewModel.visibleEntries.isEmpty {
                    Text("Nothing here yet with this filter.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.visibleEntries) { entry in
                            NavigationLink(value: entry) {
                                row(for: entry)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.delete(entry)
                                } label: {
                                    Label("Remove from library", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(Theme.screenPadding)
        }
    }

    private func row(for entry: PlayedActivity) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: entry.source.modeSystemImage)
                    .font(.caption)
                    .foregroundStyle(Theme.primary)
                Text(entry.source.modeLabel.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)
                Spacer()
                Text(shortDate(entry.playedAt))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Text(entry.activity.title)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Text("\(entry.activity.activityTimeMinutes) min")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.primary.opacity(0.12))
                    .foregroundStyle(Theme.primary)
                    .clipShape(Capsule())

                if let feedback = entry.feedback {
                    feedbackBadge(feedback)
                } else {
                    Text("Not rated")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.surface)
                        .foregroundStyle(Theme.textSecondary)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: Theme.radiusLarge).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusLarge)
                .strokeBorder(Theme.textSecondary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Theme.cardShadow, radius: 10, y: 5)
    }

    private func feedbackBadge(_ feedback: ActivityFeedback) -> some View {
        let accent = feedback.isPositive ? Theme.primary : Theme.textSecondary
        return HStack(spacing: 5) {
            Image(systemName: feedback.systemImage)
                .font(.caption2)
            Text(feedback.title)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(accent.opacity(0.12))
        .foregroundStyle(accent)
        .clipShape(Capsule())
    }

    // MARK: - Boş hâl

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: "books.vertical")
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.primary)
            }

            Text("No played games yet")
                .font(.title3.bold())
                .foregroundStyle(Theme.textPrimary)

            Text("When you tap \"Put the phone down & play\", the activity lands here — so you can play it again without generating anything.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}
