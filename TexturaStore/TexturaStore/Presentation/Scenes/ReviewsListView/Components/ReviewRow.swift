//
//  ReviewRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import SwiftUI

struct ReviewRow: View {
    
    let review: ProductReview
    let isOwnReview: Bool
    let isDeleting: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Text(formattedDate(review.createdAt))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.brand)
                    
                    Text("\(review.rating)")
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
            
            Text(review.comment ?? "—")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(uiColor: .label))
                .multilineTextAlignment(.leading)
            
            if isOwnReview {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Text(L10n.ReviewsList.Delete.action)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.red)
                }
                .disabled(isDeleting)
            }
        }
        .padding(.vertical, 18)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
