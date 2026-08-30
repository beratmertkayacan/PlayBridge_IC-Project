//
//  ActivityResultView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct ActivityResultView: View {
    @State private var viewModel: ActivityResultViewModel
    @Binding var path: NavigationPath

    init(draft: ActivityDraft, path: Binding<NavigationPath>) {
        _viewModel = State(initialValue: ActivityResultViewModel(draft: draft))
        _path = path
    }

    private var activity: PlayActivity { viewModel.activity }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(activity.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.textPrimary)

                    ActivityBodyView(activity: activity)

                    actionButtons
                }
                .padding(Theme.screenPadding)
                // Alternatif üretildiğinde içerik yumuşak bir geçişle değişsin.
                .animation(.easeInOut(duration: 0.25), value: activity.id)
            }
        }
        .navigationTitle("Your Activity")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // ANA AKSİYON: bu aktivite "oynandı" olarak işaretlenir ve
            // kütüphaneye girer. Kütüphaneye giren tek yol budur.
            PrimaryButton(
                title: "Put the phone down & play",
                isEnabled: !viewModel.isRegenerating
            ) {
                viewModel.markAsPlayed()
                path = NavigationPath()
            }

            // İKİNCİL AKSİYON: beğenilmedi, başka bir fikir gelsin.
            // Atılan öneri hiçbir yere kaydedilmez — kütüphane bir öneri
            // çöplüğü değil, gerçekten oynanmış oyunların defteri.
            Button {
                viewModel.regenerate()
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isRegenerating {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Text(viewModel.isRegenerating ? "Finding another idea..." : "Try a different idea")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .background(Color.white)
            .foregroundStyle(Theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMedium)
                    .strokeBorder(Theme.primary.opacity(0.35), lineWidth: 1)
            )
            .buttonStyle(.plain)
            .disabled(viewModel.isRegenerating)

            if viewModel.alternativeCount > 0 {
                Text("Nothing is saved until you tap play.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.top, 8)
    }
}
