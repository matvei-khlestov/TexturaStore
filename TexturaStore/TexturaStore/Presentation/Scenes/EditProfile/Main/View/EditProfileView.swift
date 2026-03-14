//
//  EditProfileView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import SwiftUI
import Combine
import UIKit
import PhotosUI

/// Экран `EditProfileView` для редактирования профиля.
///
/// Отвечает за:
/// - отображение аватара и списка редактируемых полей;
/// - выбор/замену фото через `PHPickerViewController`;
/// - взаимодействие с `EditProfileViewModelProtocol` (биндинг данных аватара и полей);
/// - обработку действий пользователя: переход к редактированию имени/почты/телефона;
/// - маршрутизацию через колбэки `onEditName`, `onEditEmail`, `onEditPhone`, `onBack`.
///
/// Особенности:
/// - Combine-подписки на изменения данных;
/// - показ ошибок сохранения аватара через алерт;
/// - доступность: расставлены `accessibilityIdentifier`;
/// - адаптивные отступы и поддержка Dynamic Type.
struct EditProfileView: View {
    
    // MARK: - Callbacks
    
    var onEditName:  (() -> Void)?
    var onEditEmail: (() -> Void)?
    var onEditPhone: (() -> Void)?
    var onBack:      (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: EditProfileViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalContent: CGFloat = 24
        }
        enum Spacing {
            static let verticalStack: CGFloat = 16
            static let tableTopPadding: CGFloat = 8
        }
        enum Avatar {
            static let size: CGFloat = 112
            static let cornerRadius: CGFloat = 56
            static let placeholderPadding: CGFloat = 18
        }
        enum Row {
            static let height: CGFloat = 65
            static let horizontalPadding: CGFloat = 16
            static let iconContainerWidth: CGFloat = 32
            static let cornerRadius: CGFloat = 14
        }
        enum ImageProcessing {
            static let jpegQuality: Double = 0.9
        }
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let avatarPlaceholder = "person.crop.circle"
        static let chevron = "chevron.right"
    }
    
    // MARK: - State
    
    @State private var avatarImage: UIImage? = nil
    
    @State private var name: String = "—"
    @State private var email: String = "—"
    @State private var phone: String = "—"
    
    @State private var isPhotoPickerPresented: Bool = false
    
    @State private var errorAlertMessage: String? = nil
    @State private var isErrorAlertPresented: Bool = false
    
    @State private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        viewModel: EditProfileViewModelProtocol,
        onEditName: (() -> Void)? = nil,
        onEditEmail: (() -> Void)? = nil,
        onEditPhone: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onEditName = onEditName
        self.onEditEmail = onEditEmail
        self.onEditPhone = onEditPhone
        self.onBack = onBack
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.Profile.Edit.title)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton {
            onBack?()
        }
        .onAppear {
            bindIfNeeded()
            viewModel.loadAvatarData()
        }
        .sheet(isPresented: $isPhotoPickerPresented) {
            PhotoPicker { result in
                handlePickerResult(result)
            }
            .ignoresSafeArea()
        }
        .alert(L10n.Common.Error.title, isPresented: $isErrorAlertPresented) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(errorAlertMessage ?? "")
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Metrics.Spacing.verticalStack) {
                avatarBlock
                
                rowsBlock
                    .padding(.top, Metrics.Spacing.tableTopPadding)
            }
            .padding(.top, Metrics.Insets.verticalContent)
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.bottom, Metrics.Insets.verticalContent)
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }
    
    // MARK: - Avatar
    
    private var avatarBlock: some View {
        VStack(spacing: Metrics.Spacing.verticalStack) {
            
            Group {
                if let avatarImage {
                    Image(uiImage: avatarImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: Symbols.avatarPlaceholder)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color(.tertiaryLabel))
                        .padding(Metrics.Avatar.placeholderPadding)
                        .background(Color(.secondarySystemBackground))
                }
            }
            .frame(width: Metrics.Avatar.size, height: Metrics.Avatar.size)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Metrics.Avatar.cornerRadius,
                    style: .continuous
                )
            )
            .clipped()
            .accessibilityIdentifier("editProfile.avatar")
            
            Button {
                isPhotoPickerPresented = true
            } label: {
                Text(L10n.Profile.Edit.changePhoto)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
            .accessibilityIdentifier("editProfile.changePhoto")
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Rows
    
    private var rowsBlock: some View {
        VStack(spacing: 0) {
            ForEach(EditProfileRow.allCases, id: \.rawValue) { row in
                rowView(row)
                if row != EditProfileRow.allCases.last {
                    Divider()
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Metrics.Row.cornerRadius, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityIdentifier("editProfile.table")
    }
    
    private func rowView(_ row: EditProfileRow) -> some View {
        Button {
            handleRowTap(row)
        } label: {
            HStack(spacing: 12) {
                
                Image(systemName: row.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(.brand))
                    .frame(width: Metrics.Row.iconContainerWidth, alignment: .leading)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.primary)
                    
                    Text(detail(for: row))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: Symbols.chevron)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, Metrics.Row.horizontalPadding)
            .frame(height: Metrics.Row.height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityId(for: row))
    }
    
    private func detail(for row: EditProfileRow) -> String {
        switch row {
        case .name:  return name
        case .email: return email
        case .phone: return phone
        }
    }
    
    private func accessibilityId(for row: EditProfileRow) -> String {
        switch row {
        case .name:  return "editProfile.row.name"
        case .email: return "editProfile.row.email"
        case .phone: return "editProfile.row.phone"
        }
    }
    
    // MARK: - Bindings
    
    private func bindIfNeeded() {
        guard bag.isEmpty else { return }
        
        viewModel.avatarDataPublisher
            .receive(on: RunLoop.main)
            .sink { data in
                avatarImage = data.flatMap(UIImage.init(data:))
            }
            .store(in: &bag)
        
        viewModel.namePublisher
            .receive(on: RunLoop.main)
            .sink { value in
                name = value
            }
            .store(in: &bag)
        
        viewModel.emailPublisher
            .receive(on: RunLoop.main)
            .sink { value in
                email = value
            }
            .store(in: &bag)
        
        viewModel.phonePublisher
            .receive(on: RunLoop.main)
            .sink { value in
                phone = value
            }
            .store(in: &bag)
    }
    
    // MARK: - Actions
    
    private func handleRowTap(_ row: EditProfileRow) {
        switch row {
        case .name:
            onEditName?()
        case .email:
            onEditEmail?()
        case .phone:
            onEditPhone?()
        }
    }
    
    private func handlePickerResult(_ result: Result<UIImage, Error>) {
        switch result {
        case .success(let image):
            Task {
                do {
                    let data = image.jpegData(compressionQuality: Metrics.ImageProcessing.jpegQuality)
                    guard let data else { return }
                    try await viewModel.saveAvatarData(data)
                } catch {
                    errorAlertMessage = error.localizedDescription
                    isErrorAlertPresented = true
                }
            }
        case .failure(let error):
            errorAlertMessage = error.localizedDescription
            isErrorAlertPresented = true
        }
    }
}

// MARK: - PhotoPicker (PHPicker)

private struct PhotoPicker: UIViewControllerRepresentable {
    
    let onFinish: (Result<UIImage, Error>) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var cfg = PHPickerConfiguration(photoLibrary: .shared())
        cfg.selectionLimit = 1
        cfg.filter = .images
        
        let vc = PHPickerViewController(configuration: cfg)
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        private let onFinish: (Result<UIImage, Error>) -> Void
        
        init(onFinish: @escaping (Result<UIImage, Error>) -> Void) {
            self.onFinish = onFinish
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            guard provider.canLoadObject(ofClass: UIImage.self) else {
                onFinish(.failure(NSError(
                    domain: "PhotoPicker",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: L10n.Profile.Edit.PhotoPicker.unableToLoadImage]
                )))
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let error {
                    self.onFinish(.failure(error))
                } else if let image = object as? UIImage {
                    self.onFinish(.success(image))
                } else {
                    self.onFinish(.failure(NSError(
                        domain: "PhotoPicker",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: L10n.Profile.Edit.PhotoPicker.invalidImageObject]
                    )))
                }
            }
        }
    }
}
