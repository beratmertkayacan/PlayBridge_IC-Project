//
//  SketchDetailView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

struct SketchDetailView: View {
    let entry: SketchEntry
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var confirmingDelete = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let image = SketchPhotoStore.load(entry.photoFileName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.radiusLarge)
                                        .strokeBorder(Theme.textSecondary.opacity(0.12), lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 7) {
                                Image(systemName: entry.category.systemImage)
                                    .font(.caption)
                                Text(entry.category.title.uppercased())
                                    .font(.caption2.weight(.bold))
                                    .tracking(0.8)
                                Text("·")
                                Text("AGE \(entry.tier.label)")
                                    .font(.caption2.weight(.bold))
                                    .tracking(0.8)
                            }
                            .foregroundStyle(Theme.textSecondary)

                            Text(entry.challengeText)
                                .font(.title3.bold())
                                .foregroundStyle(Theme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(spacing: 8) {
                            badge("\(entry.screenFreeMinutes) min screen-free")
                            badge("\(entry.points) points")
                            badge(longDate(entry.createdAt))
                        }

                        Button(role: .destructive) {
                            confirmingDelete = true
                        } label: {
                            Text("Remove from sketchbook")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .background(Color.red.opacity(0.08))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                        .padding(.top, 8)
                    }
                    .padding(Theme.screenPadding)
                }
            }
            .navigationTitle("From the sketchbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Remove this drawing?",
                isPresented: $confirmingDelete,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) { onDelete() }
                Button("Keep it", role: .cancel) {}
            } message: {
                Text("The photo will be deleted from this phone. This cannot be undone.")
            }
        }
    }

    private func badge(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(Theme.primary.opacity(0.12))
            .foregroundStyle(Theme.primary)
            .clipShape(Capsule())
    }

    private func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
