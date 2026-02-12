//
//  Bundle+AppLanguage.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import ObjectiveC.runtime

private var bundleLanguageKey: UInt8 = 0

private final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let language = objc_getAssociatedObject(self, &bundleLanguageKey) as? String else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return localizedBundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setAppLanguage(_ language: AppLanguage) {
        object_setClass(Bundle.main, LocalizedBundle.self)
        objc_setAssociatedObject(Bundle.main, &bundleLanguageKey, language.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
