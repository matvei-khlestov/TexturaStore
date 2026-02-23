//
//  ContactUsView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import SwiftUI
import MessageUI

struct ContactUsView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Data
    
    private let items: [ContactItem] = ContactItem.allCases
    
    // MARK: - State
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isAlertPresented: Bool = false
    
    @State private var isMailPresented: Bool = false
    @State private var mailRecipients: [String] = []
    
    @Environment(\.openURL) private var openURL
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { item in
                    Button {
                        handleSelection(for: item)
                    } label: {
                        row(item)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = item.detail
                        } label: {
                            Label(
                                L10n.Contact.copy,
                                systemImage: "doc.on.doc"
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.Contact.title)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton {
            onBack?()
        }
        .onAppear {
            TabBarVisibilityController.setHidden(true)
        }
        .onDisappear {
            TabBarVisibilityController.setHidden(false)
        }
        .alert(alertTitle, isPresented: $isAlertPresented) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $isMailPresented) {
            MailComposerView(
                recipients: mailRecipients,
                onFinish: { isMailPresented = false }
            )
        }
    }
    
    // MARK: - Row
    
    @ViewBuilder
    private func row(_ item: ContactItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .foregroundStyle(Color(.secondaryLabel))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .foregroundStyle(.primary)
                
                Text(item.detail)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))
            }
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }
    
    // MARK: - Selection
    
    private func handleSelection(for item: ContactItem) {
        switch item {
        case .phone:
            openPhone(item.detail.digitsOnlyKeepPlus)
            
        case .email:
            composeEmail(to: item.detail)
            
        case .address:
            let query = item.detail.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) ?? ""
            openAnyURL(raw: "http://maps.apple.com/?q=\(query)")
        }
    }
    
    // MARK: - Interactions
    
    private func composeEmail(to address: String) {
        if MFMailComposeViewController.canSendMail() {
            mailRecipients = [address]
            isMailPresented = true
            return
        }
        
        if let url = URL(string: "mailto:\(address)"),
           UIApplication.shared.canOpenURL(url) {
            openURL(url)
            return
        }
        
        UIPasteboard.general.string = address
        showAlert(
            title: L10n.Contact.Email.OpenFailed.title,
            message: L10n.Contact.Email.Copied.prefix + address
        )
    }
    
    private func openPhone(_ digits: String) {
        guard let url = URL(string: "tel://\(digits)"),
              UIApplication.shared.canOpenURL(url) else {
            UIPasteboard.general.string = digits
            showAlert(
                title: L10n.Contact.Phone.Unavailable.title,
                message: L10n.Contact.Phone.Copied.prefix + digits
            )
            return
        }
        openURL(url)
    }
    
    private func openAnyURL(raw: String) {
        guard let url = URL(string: raw),
              UIApplication.shared.canOpenURL(url) else {
            showAlert(
                title: L10n.Contact.Url.OpenFailed.title,
                message: raw
            )
            return
        }
        openURL(url)
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isAlertPresented = true
    }
}

// MARK: - Utils

private extension String {
    var digitsOnlyKeepPlus: String {
        filter { $0.isNumber || $0 == "+" }
    }
}
