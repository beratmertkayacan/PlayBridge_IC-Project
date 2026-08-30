//
//  OnboardingContainerView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()
    @State private var step: Int = 0
    let onComplete: (ChildProfile) -> Void

    private let totalSteps = 5

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                progressBar
                Group {
                    switch step {
                    case 0:
                        WelcomeStepView { step = 1 }
                    case 1:
                        AgeRangeStepView(viewModel: viewModel) { step = 2 }
                    case 2:
                        InterestsStepView(viewModel: viewModel) { step = 3 }
                    case 3:
                        MaterialsStepView(viewModel: viewModel) { step = 4 }
                    default:
                        PrivacyStepView(viewModel: viewModel) {
                            viewModel.completeOnboarding()
                        }
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: step)
            }
        }
        .onChange(of: viewModel.isOnboardingComplete) { _, isComplete in
            if isComplete, let profile = viewModel.completedProfile {
                onComplete(profile)
            }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? Theme.primary : Theme.surfaceSelected)
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, Theme.screenPadding)
        .padding(.top, 20)
    }
}
