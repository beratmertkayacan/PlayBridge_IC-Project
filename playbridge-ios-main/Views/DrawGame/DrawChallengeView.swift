//
//  DrawChallengeView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import PhotosUI
import SwiftUI

struct DrawChallengeView: View {
    @State private var viewModel: DrawGameViewModel
    @State private var pickedItem: PhotosPickerItem?
    @State private var showingBadgeMoment = false
    @State private var savedNote: String?
    @Environment(\.dismiss) private var dismiss

    init(childProfile: ChildProfile) {
        _viewModel = State(initialValue: DrawGameViewModel(childProfile: childProfile))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                    if let savedNote {
                        savedConfirmation(savedNote)
                    } else if let challenge = viewModel.challenge {
                        challengeBody(challenge)
                    } else {
                        Text("No challenge available.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, Theme.screenPadding)
            }
            .navigationTitle("Draw & Collect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onChange(of: pickedItem) { _, newItem in
            guard let newItem else { return }
            Task { await handlePicked(newItem) }
        }
        .fullScreenCover(isPresented: $showingBadgeMoment) {
            if let entry = viewModel.lastSavedEntry {
                BadgeMomentView(entry: entry, badges: viewModel.awardedBadges) {
                    showingBadgeMoment = false
                    dismiss()
                }
            }
        }
    }

    // MARK: - Görev

    @ViewBuilder
    private func challengeBody(_ challenge: DrawingChallenge) -> some View {
        VStack(spacing: 26) {
            VStack(spacing: 10) {
                HStack(spacing: 7) {
                    Image(systemName: challenge.category.systemImage)
                        .font(.caption)
                    Text(challenge.category.title.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                    Text("·")
                    Text("AGE \(challenge.tier.label)")
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                }
                .foregroundStyle(Theme.textSecondary)

                Text(challenge.text)
                    .font(.title.bold())
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if viewModel.hasActiveChallenge {
                activeState
            } else {
                idleState
            }
        }
    }

    private var idleState: some View {
        VStack(spacing: 14) {
            // Ürünün tezini görev ekranında da tekrarlıyoruz: bu uygulama
            // seni içinde tutmaya değil, dışarı çıkarmaya çalışıyor.
            Text("Read it out loud, hand them paper, and put the phone down. Come back when they're done.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            PrimaryButton(title: "Start drawing") {
                viewModel.startDrawing()
            }

            Button("Another challenge") {
                viewModel.shuffle()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.primary)
        }
    }

    private var activeState: some View {
        VStack(spacing: 14) {
            if let active = viewModel.active {
                Label(
                    "\(active.elapsedMinutes) min away from the screen so far",
                    systemImage: "clock"
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.primary.opacity(0.12)))
            }

            Text("When the drawing is finished, add a photo of it to the sketchbook.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            // Simülatörde kamera yok; kütüphaneden seçim hem demoda hem
            // gerçek kullanımda çalışıyor. Kamera ileride bunun yanına
            // ikinci bir seçenek olarak eklenebilir.
            PhotosPicker(selection: $pickedItem, matching: .images, photoLibrary: .shared()) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                    Text(viewModel.isSaving ? "Saving..." : "Add the drawing")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(viewModel.isSaving)

            Button("Not this time") {
                viewModel.cancelDrawing()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.textSecondary)
        }
    }

    /// Rozet kazanılmadığında gösterilen sade onay. Her kayıtta tören
    /// yapmak töreni değersizleştirir — rozet anı ekranı yalnızca
    /// gerçekten yeni bir rozet varsa açılıyor.
    private func savedConfirmation(_ note: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.primary)
            Text("Added to the sketchbook")
                .font(.title3.bold())
                .foregroundStyle(Theme.textPrimary)
            Text(note)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func handlePicked(_ item: PhotosPickerItem) async {
        defer { pickedItem = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        viewModel.save(image: image)

        if viewModel.awardedBadges.isEmpty {
            let minutes = viewModel.lastSavedEntry?.screenFreeMinutes ?? 0
            savedNote = "\(minutes) minutes away from the screen."
            try? await Task.sleep(for: .seconds(1.8))
            dismiss()
        } else {
            showingBadgeMoment = true
        }
    }
}
