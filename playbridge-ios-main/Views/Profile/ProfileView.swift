//
//  ProfileView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct ProfileView: View {
    let profile: ChildProfile
    let onReset: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var screenTime = ScreenTimeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 24) {
                    ScreenTimeSavedCard(viewModel: screenTime)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Child Profile")
                            .font(.title2.bold())
                            .foregroundStyle(Theme.textPrimary)
                        Text("This is what PlayBridge remembers. No name, photo, or exact age.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    infoRow(label: "Age range", value: profile.ageRange)
                    infoRow(label: "Interests", value: profile.interests.joined(separator: ", "))
                    infoRow(label: "Materials at home", value: profile.availableMaterials.joined(separator: ", "))

                    Spacer(minLength: 24)

                    Button(role: .destructive) {
                        onReset()
                        dismiss()
                    } label: {
                        Text("Reset Onboarding")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                }
                .padding(Theme.screenPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { screenTime.refresh() }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(.body)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}
