//
//  AboutTexts.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation

// MARK: - Content

enum AboutTexts {
    
    static var intro: String { L10n.About.intro }
    
    static var bullets: [(title: String, subtitle: String)] {
        [
            (L10n.About.Bullet.Quality.title, L10n.About.Bullet.Quality.subtitle),
            (L10n.About.Bullet.Range.title,   L10n.About.Bullet.Range.subtitle),
            (L10n.About.Bullet.Design.title,  L10n.About.Bullet.Design.subtitle),
            (L10n.About.Bullet.Client.title,  L10n.About.Bullet.Client.subtitle)
        ]
    }
}
