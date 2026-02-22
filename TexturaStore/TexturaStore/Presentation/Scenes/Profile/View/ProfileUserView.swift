//
//  ProfileUserView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

//
//  ProfileUserView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

/// Экран `ProfileUserView` отображает профиль пользователя и меню разделов.
///
/// Отвечает за:
/// - отображение аватара, имени и e-mail пользователя;
/// - отображение пунктов меню профиля (`ProfileUserRow`) и обработку нажатий;
/// - выполнение действий аккаунта: выход и удаление (через `ProfileUserViewModelProtocol`);
/// - показ подтверждающих диалогов и обработку ошибок.
///
/// Особенности:
/// - View не содержит бизнес-логики и не модифицирует состояние профиля напрямую;
/// - данные UI синхронизируются с ViewModel через Combine (`.onReceive`);
/// - аватар загружается из локального хранилища через `viewModel.loadAvatarData()`.
struct ProfileUserView: View {
    
    // MARK: - Callbacks
    
    var onEditProfileTap:   (() -> Void)?
    var onOrdersTap:        (() -> Void)?
    var onSettingsTap:      (() -> Void)?
    var onAboutTap:         (() -> Void)?
    var onContactTap:       (() -> Void)?
    var onPrivacyTap:       (() -> Void)?
    var onLogoutTap:        (() -> Void)?
    var onDeleteAccountTap: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: ProfileUserViewModelProtocol
    
    // MARK: - UI State
    
    @State private var userName: String = "—"
    @State private var userEmail: String = "—"
    @State private var avatarImage: Image? = nil
    
    @State private var showLogoutConfirm: Bool = false
    @State private var showDeleteConfirm: Bool = false
    
    @State private var errorMessage: String? = nil
    
    // MARK: - Init
    
    init(
        viewModel: ProfileUserViewModelProtocol,
        onEditProfileTap: (() -> Void)? = nil,
        onOrdersTap: (() -> Void)? = nil,
        onSettingsTap: (() -> Void)? = nil,
        onAboutTap: (() -> Void)? = nil,
        onContactTap: (() -> Void)? = nil,
        onPrivacyTap: (() -> Void)? = nil,
        onLogoutTap: (() -> Void)? = nil,
        onDeleteAccountTap: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onEditProfileTap = onEditProfileTap
        self.onOrdersTap = onOrdersTap
        self.onSettingsTap = onSettingsTap
        self.onAboutTap = onAboutTap
        self.onContactTap = onContactTap
        self.onPrivacyTap = onPrivacyTap
        self.onLogoutTap = onLogoutTap
        self.onDeleteAccountTap = onDeleteAccountTap
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                headerBlock
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                
                rowsBlock
                    .padding(.horizontal, 16)
                
                actionsBlock
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle(L10n.Screen.Profile.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadAvatar()
        }
        .onReceive(viewModel.userNamePublisher.removeDuplicates()) { userName = $0 }
        .onReceive(viewModel.userEmailPublisher.removeDuplicates()) { userEmail = $0 }
        .confirmationDialog(
            L10n.Profile.Logout.confirm,
            isPresented: $showLogoutConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Profile.Logout.title, role: .destructive) {
                Task { await logout() }
            }
            Button(L10n.Common.ok, role: .cancel) {}
        }
        .confirmationDialog(
            L10n.Profile.Delete.confirm,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Profile.Delete.title, role: .destructive) {
                Task { await deleteAccount() }
            }
            Button(L10n.Common.ok, role: .cancel) {}
        }
        .alert(
            L10n.Common.Error.title,
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(errorMessage ?? L10n.Profile.Error.unknown)
        }
    }
}

// MARK: - UI blocks

private extension ProfileUserView {
    
    var headerBlock: some View {
        VStack(spacing: 12) {
            avatarView
            
            Text(userName)
                .font(.system(size: 22, weight: .semibold))
                .multilineTextAlignment(.center)
            
            Text(userEmail)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    var rowsBlock: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.rows, id: \.self) { row in
                ProfileRowView(title: row.title, systemImage: row.systemImage)
                    .contentShape(Rectangle())
                    .onTapGesture { handleRowTap(row) }
                
                Divider().padding(.leading, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    var actionsBlock: some View {
        VStack(spacing: 12) {
            Button {
                showLogoutConfirm = true
            } label: {
                Label(L10n.Profile.Logout.title, systemImage: "rectangle.portrait.and.arrow.right")
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Text(L10n.Profile.Delete.title)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
        }
    }
    
    var avatarView: some View {
        Group {
            if let avatarImage {
                avatarImage
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(Circle())
    }
}

// MARK: - Actions

private extension ProfileUserView {
    
    func handleRowTap(_ row: ProfileUserRow) {
        switch row {
        case .editProfile: onEditProfileTap?()
        case .orders:      onOrdersTap?()
        case .settings:    onSettingsTap?()
        case .about:       onAboutTap?()
        case .contact:     onContactTap?()
        case .privacy:     onPrivacyTap?()
        }
    }
    
    func loadAvatar() {
        guard let data = viewModel.loadAvatarData(),
              let uiImage = UIImage(data: data) else {
            avatarImage = nil
            return
        }
        avatarImage = Image(uiImage: uiImage)
    }
    
    func logout() async {
        do {
            try await viewModel.logout()
            onLogoutTap?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async {
        do {
            try await viewModel.deleteAccount()
            onDeleteAccountTap?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}




