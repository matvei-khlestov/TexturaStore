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
    
    // MARK: - ViewModel
    
    @StateObject private var adapter: ProfileAdapter
    
    // MARK: - UI State
    
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
        _adapter = StateObject(wrappedValue: ProfileAdapter(viewModel: viewModel))
        
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
                
                // Header
                VStack(spacing: 12) {
                    avatarView
                    Text(adapter.userName)
                        .font(.system(size: 22, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    Text(adapter.userEmail)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
                
                // Rows (меню профиля)
                VStack(spacing: 8) {
                    ForEach(adapter.rows, id: \.self) { row in
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
                .padding(.horizontal, 16)
                
                // Actions
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
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(L10n.Screen.Profile.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadAvatarIfNeeded()
        }
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

// MARK: - UI parts

private extension ProfileUserView {
    
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
    
    func loadAvatarIfNeeded() {
        guard let data = adapter.viewModel.loadAvatarData(),
              let uiImage = UIImage(data: data) else {
            avatarImage = nil
            return
        }
        avatarImage = Image(uiImage: uiImage)
    }
    
    func logout() async {
        do {
            try await adapter.viewModel.logout()
            onLogoutTap?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async {
        do {
            try await adapter.viewModel.deleteAccount()
            onDeleteAccountTap?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}




