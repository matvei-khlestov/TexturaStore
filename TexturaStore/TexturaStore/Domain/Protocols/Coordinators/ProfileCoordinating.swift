//
//  ProfileCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import Foundation

@MainActor
protocol ProfileCoordinating: Coordinator {
    var onLogout: (() -> Void)? { get set }
}
