//
//  NeedMinutesInputView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct NeedMinutesInputView: View {
    @State private var viewModel: ActivityGeneratorViewModel
    @Binding var path: NavigationPath


    init(childProfile: ChildProfile, path: Binding<NavigationPath>) {
        _viewModel = State(initialValue: ActivityGeneratorViewModel(childProfile: childProfile))
        _path = path
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("I Need 15 Minutes")
                            .font(.title2.bold())
                            .foregroundStyle(Theme.textPrimary)
                        Text("Tell us how much time you have, and we'll suggest something your child can do independently.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    MinutesInputSection(
                        title: "How much time do you have?",
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
                        title: "How much setup time do you have?",
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
                            Text("Building a play idea...")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(Theme.screenPadding)
            }
        }
        .navigationTitle("I Need 15 Minutes")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.generatedResult) { _, newValue in
            if let response = newValue, let request = viewModel.lastRequest {
                let draft = ActivityDraft(response: response, source: .generated(request))
                path.append(HomeRoute.activityResult(draft))
            }
        }
    }
}
