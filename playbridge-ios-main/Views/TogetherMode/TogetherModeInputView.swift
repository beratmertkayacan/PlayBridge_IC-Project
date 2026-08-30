//
//  TogetherModeInputView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct TogetherModeInputView: View {
    @State private var viewModel: ActivityGeneratorViewModel
    @Binding var path: NavigationPath


    init(childProfile: ChildProfile, path: Binding<NavigationPath>) {
        _viewModel = State(initialValue: ActivityGeneratorViewModel(childProfile: childProfile, mode: "together"))
        _path = path
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Let's Play Together")
                            .font(.title2.bold())
                            .foregroundStyle(Theme.textPrimary)
                        Text(togetherIntro)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    MinutesInputSection(
                        title: "How much time do you have together?",
                        options: viewModel.durationOptions,
                        selected: viewModel.selectedDuration,
                        extraChip: viewModel.extraDurationChip,
                        placeholder: "Or type minutes, e.g. 12",
                        manualInput: $viewModel.manualDurationInput,
                        canAdd: viewModel.canAddManualDuration,
                        onSelect: { viewModel.selectDuration($0) },
                        onAddManual: { viewModel.addManualDuration() }
                    )
                    MinutesInputSection(
                        title: "How much setup time do you need first?",
                        options: viewModel.setupTimeOptions,
                        selected: viewModel.selectedSetupTime,
                        extraChip: viewModel.extraSetupChip,
                        placeholder: "Or type minutes, e.g. 3",
                        manualInput: $viewModel.manualSetupInput,
                        canAdd: viewModel.canAddManualSetup,
                        onSelect: { viewModel.selectSetupTime($0) },
                        onAddManual: { viewModel.addManualSetup() }
                    )
                    LocationSection(viewModel: viewModel)
                    MaterialsSection(viewModel: viewModel)

                    PrimaryButton(
                        title: viewModel.isGenerating ? "Generating..." : "Generate Activity",
                        isEnabled: viewModel.canGenerate && !viewModel.isGenerating
                    ) {
                        viewModel.generateActivity()
                    }

                    if viewModel.isGenerating {
                        VStack(spacing: 10) {
                            ProgressView()
                            Text(togetherLoadingLine)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(Theme.screenPadding)
            }
        }
        .navigationTitle("Let's Play Together")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.generatedResult) { _, newValue in
            if let response = newValue, let request = viewModel.lastRequest {
                let draft = ActivityDraft(response: response, source: .generated(request))
                path.append(HomeRoute.activityResult(draft))
            }
        }
    }

    private var togetherIntro: String {
        if viewModel.nothingInHand {
            return "Nothing in hand. We will make a looking and guessing game from the windows."
        }
        return "Tell us what you have, and we will suggest something you can build and imagine together."
    }

    private var togetherLoadingLine: String {
        viewModel.nothingInHand
            ? "Finding a looking game..."
            : "Building something to create together..."
    }
}
