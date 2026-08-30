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
                        Text("Tell us what you have, and we'll suggest something you can build and imagine together.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    durationSection
                    setupTimeSection
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
                            Text("Building something to create together...")
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

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How much time do you have together?")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            FlowLayout(spacing: 10) {
                ForEach(viewModel.durationOptions, id: \.self) { minutes in
                    SelectableChip(
                        title: "\(minutes) min",
                        isSelected: viewModel.selectedDuration == minutes
                    ) {
                        viewModel.selectedDuration = minutes
                    }
                }
            }
        }
    }

    private var setupTimeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How much setup time do you need first?")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            FlowLayout(spacing: 10) {
                ForEach(viewModel.setupTimeOptions, id: \.self) { minutes in
                    SelectableChip(
                        title: "\(minutes) min",
                        isSelected: viewModel.selectedSetupTime == minutes
                    ) {
                        viewModel.selectedSetupTime = minutes
                    }
                }
            }
        }
    }

}
