//
//  CapsuleFlowGrid.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

/// Flow-grid, который раскладывает элементы по строкам с переносом (self-sizing как в UIKit).
/// В отличие от LazyVGrid, не раздаёт “ширину колонки”, поэтому капсулы не выглядят разъехавшимися.
struct CapsuleFlowGrid<Data, ID: Hashable, Content: View>: View {
    
    // MARK: - Props
    
    let items: [Data]
    let id: KeyPath<Data, ID>
    let content: (Data) -> Content
    
    // MARK: - Body
    
    var body: some View {
        FlowLayout(
            hSpacing: CapsuleFlowGridMetrics.hSpacing,
            vSpacing: CapsuleFlowGridMetrics.vSpacing
        ) {
            ForEach(items, id: id) { item in
                content(item)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.top, CapsuleFlowGridMetrics.topPadding)
    }
}

// MARK: - FlowLayout

private struct FlowLayout<Content: View>: View {
    
    let hSpacing: CGFloat
    let vSpacing: CGFloat
    let content: Content
    
    init(
        hSpacing: CGFloat,
        vSpacing: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Flow(hSpacing: hSpacing, vSpacing: vSpacing) {
                content
            }
        } else {}
    }
}

private struct Flow: Layout {
    
    let hSpacing: CGFloat
    let vSpacing: CGFloat
    
    @available(iOS 16.0, *)
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + vSpacing
                rowHeight = 0
            }
            
            x += (x > 0 ? hSpacing : 0) + size.width
            rowHeight = max(rowHeight, size.height)
        }
        
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + rowHeight)
    }
    
    @available(iOS 16.0, *)
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + vSpacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            
            x += size.width + hSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Metrics

private enum CapsuleFlowGridMetrics {
    static let hSpacing: CGFloat = 10
    static let vSpacing: CGFloat = 10
    static let topPadding: CGFloat = 8
}
