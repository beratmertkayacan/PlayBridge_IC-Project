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
    @State private var confirmingEndSession = false

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

                    VStack(alignment: .leading, spacing: 10) {
                        Button(role: .destructive) {
                            confirmingEndSession = true
                        } label: {
                            Text("End session")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .background(Color.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))

                        // Geri donusu olmayan bir islem: ne olacagini
                        // butona basmadan ONCE soyluyoruz.
                        Text("Everything from this session is deleted and the app starts over from onboarding.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(Theme.screenPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "End this session?",
                isPresented: $confirmingEndSession,
                titleVisibility: .visible
            ) {
                Button("End session", role: .destructive) {
                    onReset()
                    dismiss()
                }
                Button("Keep everything", role: .cancel) {}
            } message: {
                // Neyin silinecegini tek tek sayiyoruz. "Emin misiniz?"
                // diye sorup listeyi gostermemek, kullanicinin bilmedigi
                // bir seyi onaylamasina yol acar.
                Text("This deletes the child profile, every saved activity and rating, the whole sketchbook with its photos, and all badges earned. Nothing can be recovered, and the app returns to the first onboarding step.")
            }
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
