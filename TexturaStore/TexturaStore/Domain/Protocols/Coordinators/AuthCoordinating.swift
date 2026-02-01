//
//  AuthCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import Foundation

protocol AuthCoordinating: Coordinator {
    var onAuthSuccess: (() -> Void)? { get set }
}
