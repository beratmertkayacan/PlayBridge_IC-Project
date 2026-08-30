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

    init(childProfile: ChildProfile, path: Binding<NavigationPath>) {
        _viewModel = State(initialValue: MealModeViewModel(childProfile: childProfile))
        _path = path
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                if viewModel.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Thinking of something fun to ask...")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else if let prompt = viewModel.prompt {
                    Text(prompt)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 14) {
                    PrimaryButton(title: "Put the phone down and try it") {
                        path = NavigationPath()
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
        }
        .navigationTitle("Meal Mode")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.prompt == nil {
                viewModel.fetchNewPrompt()
            }
        }
    }
}
