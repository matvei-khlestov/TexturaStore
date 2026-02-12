//
//  AboutView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import SwiftUI

struct AboutView: View {

    // MARK: - Callbacks

    var onBack: (() -> Void)?

    // MARK: - Metrics

    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let vertical: CGFloat = 24
        }
        enum Spacing {
            static let verticalStack: CGFloat = 20
            static let bulletRow: CGFloat = 12
            static let bulletLabels: CGFloat = 4
        }
        enum Sizes {
            static let bulletIcon: CGFloat = 22
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.Spacing.verticalStack) {

                introText

                bullets
            }
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.vertical, Metrics.Insets.vertical)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.Profile.Menu.about)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton {
            onBack?()
        }
    }

    // MARK: - Intro

    private var introText: some View {
        Text(AboutTexts.intro)
            .font(.body)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
    }

    // MARK: - Bullets

    private var bullets: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.bulletRow) {
            ForEach(AboutTexts.bullets.indices, id: \.self) { index in
                bulletRow(
                    title: AboutTexts.bullets[index].title,
                    subtitle: AboutTexts.bullets[index].subtitle
                )
            }
        }
    }

    @ViewBuilder
    private func bulletRow(
        title: String,
        subtitle: String
    ) -> some View {
        HStack(alignment: .top, spacing: Metrics.Spacing.bulletRow) {

            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(
                    width: Metrics.Sizes.bulletIcon,
                    height: Metrics.Sizes.bulletIcon
                )
                .foregroundStyle(Color(.brand))

            VStack(alignment: .leading, spacing: Metrics.Spacing.bulletLabels) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
    }
}
