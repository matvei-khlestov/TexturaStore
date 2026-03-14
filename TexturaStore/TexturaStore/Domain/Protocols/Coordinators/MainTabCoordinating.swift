//
//  MainTabCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import Foundation

protocol MainTabCoordinating: Coordinator {
    var onLogout: (() -> Void)? { get set }
}
