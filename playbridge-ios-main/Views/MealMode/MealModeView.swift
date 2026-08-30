//
//  MealModeView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct MealModeView: View {
    @State private var viewModel: MealModeViewModel
    @Binding var path: NavigationPath
    @State private var showingReward = false

    init(childProfile: ChildProfile, path: Binding<NavigationPath>) {
        _viewModel = State(initialValue: MealModeViewModel(childProfile: childProfile))
        _path = path
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                if showingReward {
                    rewardState
                } else if viewModel.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Thinking of something fun to ask...")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else if let prompt = viewModel.prompt {
                    promptState(prompt)
                }

                Spacer()

                if !showingReward {
                    footer
                }
            }
        }
        .navigationTitle("Meal Mode")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.prompt == nil {
                viewModel.fetchNewPrompt()
            }
        }
    }

    // MARK: - Soru

    private func promptState(_ prompt: String) -> some View {
        VStack(spacing: 18) {
            // Konu etiketi: ebeveyn sorunun neye baktığını bir bakışta
            // görsün diye. Konuyu uygulama seçiyor — masaya oturmuş
            // birine önce kategori seçtirmek Meal Mode'un tüm değerini
            // yok ederdi.
            HStack(spacing: 7) {
                Image(systemName: viewModel.category.systemImage)
                    .font(.caption)
                Text(viewModel.category.label)
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
            }
            .foregroundStyle(Theme.textSecondary)

            Text(prompt)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Ödül

    /// Rozet kazanıldığında sorunun yerine kısaca bu geçiyor.
    ///
    /// Tam ekran bir tören yok: masadasın, çocuk karşında, telefonun
    /// sahneyi devralması yanlış olur. İki saniye görünüp çekiliyor.
    private var rewardState: some View {
        VStack(spacing: 14) {
            if let badge = viewModel.awardedBadges.first {
                BadgeStamp(badge: badge, size: 88)
                Text(badge.title)
                    .font(.title2.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text(badge.caption)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    // MARK: - Alt kısım

    private var footer: some View {
        VStack(spacing: 14) {
            badgeShelf

            PrimaryButton(title: "Put the phone down and try it") {
                viewModel.markAsked()
                if viewModel.awardedBadges.isEmpty {
                    path = NavigationPath()
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) { showingReward = true }
                    Task {
                        try? await Task.sleep(for: .seconds(2.2))
                        path = NavigationPath()
                    }
                }
            }

            Button("Try another") {
                viewModel.fetchNewPrompt()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.primary)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, Theme.screenPadding)
        .padding(.bottom, 24)
    }

    /// Kazanılmış rozetler ve toplam sayaç. Kazanılmamışlar da soluk
    /// görünüyor — koleksiyonun devamı olduğunu göstermek, boşluğu
    /// gizlemekten daha iyi bir motivasyon.
    private var badgeShelf: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ForEach(MealBadge.allCases) { badge in
                    BadgeStamp(
                        badge: badge,
                        size: 34,
                        isEarned: viewModel.earnedBadges.contains(badge)
                    )
                    .opacity(viewModel.earnedBadges.contains(badge) ? 1 : 0.35)
                }
            }

            if viewModel.totalAsked > 0 {
                Text("\(viewModel.totalAsked) \(viewModel.totalAsked == 1 ? "question" : "questions") asked at the table")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.bottom, 4)
    }
}
