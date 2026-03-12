//
//  CommentInputSheetView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import SwiftUI
import Combine

/// View `CommentInputSheetView` для экрана ввода комментария.
///
/// Отвечает за:
/// - отображение текстового поля для комментария (`FormTextView`);
/// - валидацию комментария через `CommentInputSheetViewModelProtocol`;
/// - сохранение результата через `onSaveComment`;
/// - закрытие шита и визуальную обратную связь при ошибках.
///
/// Взаимодействует с:
/// - `CommentInputSheetViewModelProtocol` — хранение и валидация комментария (Combine);
/// - `FormTextView` — отображение текстового поля с ошибками.
///
/// Особенности:
/// - реактивное обновление текста и ошибок (`commentPublisher`, `errorPublisher`);
/// - сохранение значения через колбэк `onSaveComment`.
struct CommentInputSheetView: View {
    
    // MARK: - VM
    
    private let viewModel: any CommentInputSheetViewModelProtocol
    
    // MARK: - Callback
    
    var onSaveComment: ((String) -> Void)?
    
    // MARK: - State
    
    @State private var commentText: String = ""
    @State private var errorMessage: String?
    
    // MARK: - Env
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let textViewHeight: CGFloat = 140
            static let buttonHeight: CGFloat = 52
            static let buttonCornerRadius: CGFloat = 16
        }
        
        enum Insets {
            static let horizontal: CGFloat = 16
            static let top: CGFloat = 20
            static let bottom: CGFloat = 20
        }
        
        enum Spacing {
            static let content: CGFloat = 16
        }
    }
    
    // MARK: - Init
    
    init(
        viewModel: any CommentInputSheetViewModelProtocol,
        onSaveComment: ((String) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onSaveComment = onSaveComment
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.content) {
            FormTextView(
                title: nil,
                placeholder: L10n.CommentInput.placeholder,
                text: $commentText,
                errorMessage: errorMessage,
                forceShowError: errorMessage != nil,
                fixedHeight: Metrics.Sizes.textViewHeight,
                onTextChanged: { text in
                    viewModel.setComment(text)
                }
            )
            
            Button(action: saveTapped) {
                Text(L10n.CommentInput.save)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Metrics.Sizes.buttonHeight)
                    .background(
                        RoundedRectangle(
                            cornerRadius: Metrics.Sizes.buttonCornerRadius,
                            style: .continuous
                        )
                        .fill(Color(uiColor: .brand))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Metrics.Insets.horizontal)
        .padding(.top, Metrics.Insets.top)
        .padding(.bottom, Metrics.Insets.bottom)
        .navigationTitle(L10n.CommentInput.Navigation.title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(viewModel.commentPublisher.removeDuplicates()) { text in
            commentText = text
        }
        .onReceive(viewModel.errorPublisher) { message in
            errorMessage = message
        }
        .onAppear {
            commentText = viewModel.comment
        }
    }
}

// MARK: - Actions

private extension CommentInputSheetView {
    
    func saveTapped() {
        if viewModel.validate() {
            onSaveComment?(viewModel.comment.trimmingCharacters(in: .whitespacesAndNewlines))
            dismiss()
        }
    }
}
