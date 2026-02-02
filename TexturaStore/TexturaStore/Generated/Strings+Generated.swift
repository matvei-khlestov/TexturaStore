// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Screen {
    internal enum Cart {
      /// Cart
      internal static let title = L10n.tr("Localizable", "screen.cart.title", fallback: "Cart")
    }
    internal enum Catalog {
      /// Catalog
      internal static let title = L10n.tr("Localizable", "screen.catalog.title", fallback: "Catalog")
    }
    internal enum Favorites {
      /// Favorites
      internal static let title = L10n.tr("Localizable", "screen.favorites.title", fallback: "Favorites")
    }
    internal enum Profile {
      /// Profile
      internal static let title = L10n.tr("Localizable", "screen.profile.title", fallback: "Profile")
    }
  }
  internal enum Tab {
    /// Cart
    internal static let cart = L10n.tr("Localizable", "tab.cart", fallback: "Cart")
    /// Localizable.strings
    ///   TexturaStore
    /// 
    ///   Created by Matvei Khlestov on 02.02.2026.
    internal static let catalog = L10n.tr("Localizable", "tab.catalog", fallback: "Catalog")
    /// Favorites
    internal static let favorites = L10n.tr("Localizable", "tab.favorites", fallback: "Favorites")
    /// Profile
    internal static let profile = L10n.tr("Localizable", "tab.profile", fallback: "Profile")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
