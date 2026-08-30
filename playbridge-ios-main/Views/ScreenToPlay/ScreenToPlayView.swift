//
//  ScreenToPlayView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct ScreenToPlayView: View {
    @State private var viewModel: ScreenToPlayViewModel
    @Binding var path: NavigationPath

    init(childProfile: ChildProfile, path: Binding<NavigationPath>) {
        _viewModel = State(initialValue: ScreenToPlayViewModel(childProfile: childProfile))
        _path = path
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Theme.primary.opacity(0.12))
                            .frame(width: 88, height: 88)
                        Image(systemName: "sparkles.tv")
                            .font(.system(size: 32))
                            .foregroundStyle(Theme.primary)
                    }

                    VStack(spacing: 6) {
                        Text("Turn Screen Into Play")
                            .font(.title2.bold())
                            .foregroundStyle(Theme.textPrimary)
                        Text("What did they watch, or what do they want to watch? A word or two is enough.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    TextField("e.g. Dinosaurs for Kids", text: $viewModel.screenTopic)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.radiusMedium)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusMedium)
                                .strokeBorder(Theme.textSecondary.opacity(0.15), lineWidth: 1)
                        )

                    PrimaryButton(
                        title: viewModel.isGenerating ? "Creating..." : "Turn This Into Play",
                        isEnabled: viewModel.canGenerate && !viewModel.isGenerating
                    ) {
                        viewModel.generate()
                    }

                    if viewModel.isGenerating {
                        VStack(spacing: 10) {
                            ProgressView()
                            Text("Screen finished. Now create your own world.")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, Theme.screenPadding)

                Spacer()
                Spacer()
            }
        }
        .navigationTitle("Turn Screen Into Play")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.generatedResult) { _, newValue in
            if let response = newValue, let topic = viewModel.lastTopic {
                let draft = ActivityDraft(
                    response: response,
                    source: .screenToPlay(ageRange: viewModel.childProfile.ageRange, topic: topic)
                )
                path.append(HomeRoute.activityResult(draft))
            }
        }
    }
}
