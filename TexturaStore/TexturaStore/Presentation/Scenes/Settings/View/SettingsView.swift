//
//  SettingsView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import SwiftUI
import Combine

struct SettingsView: View {

    // MARK: - Callbacks

    var onBack: (() -> Void)?

    // MARK: - Dependencies

    private let viewModel: any SettingsViewModelProtocol

    // MARK: - State (UI)

    @State private var selectedLanguage: AppLanguage = .ru
    @State private var selectedTheme: AppTheme = .system
    @State private var bag = Set<AnyCancellable>()

    // MARK: - Init

    init(
        viewModel: any SettingsViewModelProtocol,
        onBack: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    // MARK: - Body

    var body: some View {
        List {
            languageSection
            appearanceSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.Settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton { onBack?() }
        .onAppear {
            syncFromViewModel()
            bindIfNeeded()
        }
    }
}

// MARK: - Sections

private extension SettingsView {

    var languageSection: some View {
        Section {
            Picker("", selection: $selectedLanguage) {
                ForEach(AppLanguage.allCases) { item in
                    Text(item.title)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedLanguage) { newValue in
                viewModel.setLanguage(newValue)
            }
        } header: {
            Label(L10n.Settings.Language.header, systemImage: SettingsSymbols.language)
        } footer: {
            Text(L10n.Settings.Language.footer)
        }
    }

    var appearanceSection: some View {
        Section {
            Picker("", selection: $selectedTheme) {
                ForEach(AppTheme.allCases) { item in
                    Text(item.title)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedTheme) { newValue in
                viewModel.setTheme(newValue)
            }
        } header: {
            Label(L10n.Settings.Theme.header, systemImage: SettingsSymbols.appearance)
        } footer: {
            Text(L10n.Settings.Theme.footer)
        }
    }
}

// MARK: - Bindings

private extension SettingsView {

    func syncFromViewModel() {
        selectedLanguage = viewModel.currentLanguage
        selectedTheme = viewModel.currentTheme
    }

    func bindIfNeeded() {
        guard bag.isEmpty else { return }

        viewModel.language
            .receive(on: RunLoop.main)
            .sink { value in
                selectedLanguage = value
            }
            .store(in: &bag)

        viewModel.theme
            .receive(on: RunLoop.main)
            .sink { value in
                selectedTheme = value
            }
            .store(in: &bag)
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 16.0, *) {
        let storage = UserDefaultsSettingsStorage(userDefaults: .standard)
        let service = SettingsService(storage: storage)

        NavigationStack {
            SettingsView(
                viewModel: SettingsViewModel(service: service),
                onBack: {}
            )
        }
        .preferredColorScheme(service.preferredColorScheme)
    }
}
