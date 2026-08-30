//
//  HomeDashboardView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct HomeDashboardView: View {
    let childProfile: ChildProfile
    let onResetProfile: () -> Void

    @State private var viewModel = HomeViewModel()
    @State private var path = NavigationPath()
    @State private var showingProfile = false
    @State private var showingLibrary = false
    @State private var showingDrawGame = false

    // Bandın durumu doğrudan depodan okunuyor. Buraya ayrı bir ViewModel
    // koymuyoruz: bant yalnızca gösterim yapıyor, asıl oyun mantığı
    // DrawChallengeView'ın kendi ViewModel'inde duruyor.
    @State private var drawWeekCount = 0
    @State private var activeChallengeText: String?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        header

                        // Geri bildirim kartı: sadece önceki bir açılışta
                        // oynanmış ve henüz puanlanmamış bir kayıt varsa
                        // görünüyor. Grid'in ÜSTÜNDE duruyor çünkü tek
                        // dokunuşluk ve kaçırılmaması gereken bir soru.
                        if let entry = viewModel.pendingFeedbackEntry {
                            FeedbackPromptCard(
                                entry: entry,
                                onSelect: { viewModel.submitFeedback($0) },
                                onDismiss: { viewModel.dismissFeedback() }
                            )
                            .padding(.horizontal, Theme.screenPadding)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        } else if viewModel.justThanked {
                            thankYouNote
                        }

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(HomeMode.allCases) { mode in
                                ModeCard(
                                    title: mode.title,
                                    subtitle: mode.subtitle,
                                    systemImage: mode.systemImage
                                ) {
                                    handleTap(on: mode)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.screenPadding)

                        DrawGameBanner(
                            weekCount: drawWeekCount,
                            weeklyGoal: SketchStore.weeklyGoal,
                            hasActiveChallenge: activeChallengeText != nil,
                            activeChallengeText: activeChallengeText
                        ) {
                            showingDrawGame = true
                        }
                        .padding(.horizontal, Theme.screenPadding)

                        Text("Designed to help you leave the screen, not stay on it.")
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 48)
                    }
                    .padding(.vertical, 36)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.pendingFeedbackEntry)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 14) {
                        Button {
                            showingLibrary = true
                        } label: {
                            Image(systemName: "books.vertical")
                                .foregroundStyle(Theme.primary)
                        }
                        .accessibilityLabel("Play Library")

                        Button {
                            showingProfile = true
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .foregroundStyle(Theme.primary)
                        }
                        .accessibilityLabel("Child Profile")
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(profile: childProfile, onReset: onResetProfile)
            }
            .sheet(isPresented: $showingLibrary) {
                PlayLibraryView()
            }
            .sheet(isPresented: $showingDrawGame, onDismiss: refreshDrawGame) {
                DrawChallengeView(childProfile: childProfile)
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .needMinutes:
                    NeedMinutesInputView(childProfile: childProfile, path: $path)
                case .playTogether:
                    TogetherModeInputView(childProfile: childProfile, path: $path)
                case .mealMode:
                    MealModeView(childProfile: childProfile, path: $path)
                case .screenToPlay:
                    ScreenToPlayView(childProfile: childProfile, path: $path)
                case .activityResult(let draft):
                    ActivityResultView(draft: draft, path: $path)
                }
            }
        }
        .onAppear {
            // Ana ekrana her dönüşte kontrol ediyoruz: ebeveyn bir oyunu
            // yeni işaretlemiş olabilir, ya da uygulamayı yeni açmış olabilir.
            viewModel.refreshPendingFeedback()
            refreshDrawGame()
        }
    }

    private var thankYouNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.primary)
            Text("Thanks, that helps.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .transition(.opacity)
    }

    /// Banda yansıyan iki bilgi: bu haftaki çizim sayısı ve yarım
    /// kalmış bir görev olup olmadığı. Ebeveyn görevi başlatıp
    /// uygulamayı kapatabilir — döndüğünde bandın onu beklediğini
    /// görmesi gerekiyor.
    private func refreshDrawGame() {
        drawWeekCount = SketchStore.currentWeek().count
        activeChallengeText = ActiveChallengeStore.load()?.challenge.text
    }

    private func handleTap(on mode: HomeMode) {
        switch mode {
        case .need15Minutes:
            path.append(HomeRoute.needMinutes)
        case .playTogether:
            path.append(HomeRoute.playTogether)
        case .mealMode:
            path.append(HomeRoute.mealMode)
        case .screenToPlay:
            path.append(HomeRoute.screenToPlay)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("PlayBridge AI")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
            Text("What do you need right now?")
                .font(.title.bold())
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}

#Preview {
    HomeDashboardView(
        childProfile: ChildProfile(
            ageRange: "3-4",
            interests: ["Dinosaurs"],
            availableMaterials: ["Paper", "Crayons"],
            preferredActivityDuration: 15
        ),
        onResetProfile: {}
    )
}
