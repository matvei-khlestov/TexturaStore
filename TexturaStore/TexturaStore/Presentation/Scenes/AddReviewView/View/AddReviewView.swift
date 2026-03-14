//
//  AddReviewView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import SwiftUI
import Combine

/// Экран добавления отзыва.
///
/// Отвечает за:
/// - ввод текста отзыва через `FormTextView`;
/// - выбор рейтинга через звёзды;
/// - биндинг к `AddReviewViewModelProtocol` через Combine;
/// - отображение ошибок валидации;
/// - возврат назад после успешного добавления отзыва.
///
/// Особенности:
/// - это обычный экран в navigation stack;
/// - без bottom sheet;
/// - без кнопки-крестика;
/// - после успешной отправки вызывается `onBack`.
struct AddReviewView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: any AddReviewViewModelProtocol
    
    // MARK: - State
    
    @State private var commentText: String = ""
    @State private var rating: Int = 0
    @State private var isSubmitting: Bool = false
    @State private var isSubmitEnabled: Bool = false
    @State private var commentError: String?
    @State private var ratingError: String?
    
    // MARK: - Init
    
    init(
        viewModel: any AddReviewViewModelProtocol,
        onBack: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.Spacing.content) {
                Text(L10n.AddReview.Screen.title)
                    .font(.system(size: Metrics.Fonts.screenTitle, weight: .bold))
                    .foregroundStyle(Color(uiColor: .label))
                
                FormTextView(
                    title: L10n.AddReview.Comment.title,
                    placeholder: L10n.AddReview.Comment.placeholder,
                    text: $commentText,
                    errorMessage: commentError,
                    forceShowError: commentError != nil,
                    maxLength: Metrics.Limits.commentMaxLength,
                    fixedHeight: Metrics.Sizes.textViewHeight,
                    onTextChanged: { text in
                        viewModel.setComment(text)
                    }
                )
                
                VStack(alignment: .leading, spacing: Metrics.Spacing.ratingBlock) {
                    Text("\(L10n.AddReview.Rating.title): \(rating)")
                        .font(.system(size: Metrics.Fonts.ratingTitle, weight: .bold))
                        .foregroundStyle(Color(uiColor: .label))
                    
                    HStack(spacing: Metrics.Spacing.stars) {
                        ForEach(1...5, id: \.self) { index in
                            Button(action: {
                                viewModel.setRating(index)
                            }) {
                                Image(systemName: index <= rating ? Symbols.starFilled : Symbols.star)
                                    .font(.system(size: Metrics.Fonts.starSize, weight: .semibold))
                                    .foregroundStyle(
                                        index <= rating
                                        ? Color(uiColor: .systemYellow)
                                        : Color(uiColor: .systemGray3)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    if let ratingError, !ratingError.isEmpty {
                        Text(ratingError)
                            .font(.system(size: Metrics.Fonts.error, weight: .regular))
                            .foregroundStyle(Color(uiColor: .systemRed))
                            .lineLimit(2)
                    }
                }
                
                Button(action: {
                    viewModel.submitReview()
                }) {
                    Text(L10n.AddReview.submit)
                        .font(.system(size: Metrics.Fonts.submitTitle, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.Sizes.submitHeight)
                        .background(
                            RoundedRectangle(
                                cornerRadius: Metrics.Corners.submit,
                                style: .continuous
                            )
                            .fill(
                                isSubmitEnabled
                                ? Color(uiColor: .brand)
                                : Color(uiColor: .systemGray3)
                            )
                        )
                }
                .buttonStyle(.plain)
                .disabled(!isSubmitEnabled || isSubmitting)
                .padding(.top, Metrics.Spacing.submitTop)
            }
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.top, Metrics.Insets.top)
            .padding(.bottom, Metrics.Insets.bottom)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(L10n.AddReview.Navigation.title)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton {
            onBack?()
        }
        .onAppear {
            commentText = viewModel.comment
            rating = viewModel.rating
            isSubmitting = viewModel.isSubmitting
        }
        .onReceive(viewModel.commentPublisher.removeDuplicates()) { value in
            commentText = value
        }
        .onReceive(viewModel.ratingPublisher.removeDuplicates()) { value in
            rating = value
        }
        .onReceive(viewModel.isSubmittingPublisher.removeDuplicates()) { value in
            isSubmitting = value
        }
        .onReceive(viewModel.isSubmitEnabledPublisher.removeDuplicates()) { value in
            isSubmitEnabled = value
        }
        .onReceive(viewModel.commentErrorPublisher) { value in
            commentError = value
        }
        .onReceive(viewModel.ratingErrorPublisher) { value in
            ratingError = value
        }
        .onReceive(viewModel.didSubmitPublisher) { _ in
            onBack?()
        }
    }
}

// MARK: - Constants

private extension AddReviewView {
    
    enum Symbols {
        static let star = "star.fill"
        static let starFilled = "star.fill"
    }
    
    enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let top: CGFloat = 20
            static let bottom: CGFloat = 20
        }
        
        enum Spacing {
            static let content: CGFloat = 24
            static let ratingBlock: CGFloat = 12
            static let stars: CGFloat = 12
            static let submitTop: CGFloat = 8
        }
        
        enum Fonts {
            static let screenTitle: CGFloat = 28
            static let ratingTitle: CGFloat = 18
            static let starSize: CGFloat = 34
            static let submitTitle: CGFloat = 18
            static let error: CGFloat = 13
        }
        
        enum Sizes {
            static let textViewHeight: CGFloat = 180
            static let submitHeight: CGFloat = 56
        }
        
        enum Corners {
            static let submit: CGFloat = 10
        }
        
        enum Limits {
            static let commentMaxLength: Int = 500
        }
    }
}
