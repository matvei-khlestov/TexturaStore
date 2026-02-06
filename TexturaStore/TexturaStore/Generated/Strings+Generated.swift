// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Auth {
    internal enum Reset {
      /// Back to Sign In
      internal static let backRowAction = L10n.tr("Localizable", "auth.reset.backRowAction", fallback: "Back to Sign In")
      /// Remembered your password?
      internal static let backRowLabel = L10n.tr("Localizable", "auth.reset.backRowLabel", fallback: "Remembered your password?")
      /// Send
      internal static let submit = L10n.tr("Localizable", "auth.reset.submit", fallback: "Send")
      /// Enter your e-mail and we will send a password reset link.
      internal static let subtitle = L10n.tr("Localizable", "auth.reset.subtitle", fallback: "Enter your e-mail and we will send a password reset link.")
      /// Auth - Reset Password
      internal static let title = L10n.tr("Localizable", "auth.reset.title", fallback: "Password reset")
      internal enum Alert {
        internal enum Done {
          /// We sent you an email. Check your inbox.
          internal static let message = L10n.tr("Localizable", "auth.reset.alert.done.message", fallback: "We sent you an email. Check your inbox.")
          /// Done
          internal static let title = L10n.tr("Localizable", "auth.reset.alert.done.title", fallback: "Done")
        }
      }
    }
    internal enum Root {
      internal enum Signin {
        /// Auth - Root
        internal static let title = L10n.tr("Localizable", "auth.root.signin.title", fallback: "Sign In")
      }
      internal enum Signup {
        /// Sign Up
        internal static let title = L10n.tr("Localizable", "auth.root.signup.title", fallback: "Sign Up")
      }
    }
    internal enum Signin {
      /// Auth - Sign In
      internal static let forgotPassword = L10n.tr("Localizable", "auth.signin.forgotPassword", fallback: "Forgot password?")
      /// Sign Up
      internal static let noteAction = L10n.tr("Localizable", "auth.signin.noteAction", fallback: "Sign Up")
      /// Don't have an account?
      internal static let noteText = L10n.tr("Localizable", "auth.signin.noteText", fallback: "Don't have an account?")
      /// Sign In
      internal static let submit = L10n.tr("Localizable", "auth.signin.submit", fallback: "Sign In")
    }
    internal enum Signup {
      /// Sign In
      internal static let noteAction = L10n.tr("Localizable", "auth.signup.noteAction", fallback: "Sign In")
      /// Already have an account?
      internal static let noteText = L10n.tr("Localizable", "auth.signup.noteText", fallback: "Already have an account?")
      /// Auth - Sign Up
      internal static let privacyTitle = L10n.tr("Localizable", "auth.signup.privacyTitle", fallback: "Privacy Policy")
      /// Sign Up
      internal static let submit = L10n.tr("Localizable", "auth.signup.submit", fallback: "Sign Up")
      internal enum Agreement {
        /// You must agree to the privacy policy
        internal static let error = L10n.tr("Localizable", "auth.signup.agreement.error", fallback: "You must agree to the privacy policy")
      }
      internal enum Success {
        /// We sent an email to confirm your email address.
        /// 
        /// Confirm your email and sign in to the app.
        /// 
        /// You will be redirected to the Sign In screen.
        internal static let message = L10n.tr("Localizable", "auth.signup.success.message", fallback: "We sent an email to confirm your email address.\n\nConfirm your email and sign in to the app.\n\nYou will be redirected to the Sign In screen.")
        /// Registration successful
        internal static let title = L10n.tr("Localizable", "auth.signup.success.title", fallback: "Registration successful")
      }
    }
  }
  internal enum Common {
    /// OK
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "OK")
    internal enum Error {
      /// Common
      internal static let title = L10n.tr("Localizable", "common.error.title", fallback: "Error")
    }
  }
  internal enum Form {
    internal enum Field {
      internal enum Email {
        /// Enter e-mail
        internal static let placeholder = L10n.tr("Localizable", "form.field.email.placeholder", fallback: "Enter e-mail")
        /// E-mail
        internal static let title = L10n.tr("Localizable", "form.field.email.title", fallback: "E-mail")
      }
      internal enum Name {
        /// Enter name
        internal static let placeholder = L10n.tr("Localizable", "form.field.name.placeholder", fallback: "Enter name")
        /// Form - Fields
        internal static let title = L10n.tr("Localizable", "form.field.name.title", fallback: "Name")
      }
      internal enum Password {
        /// Enter password
        internal static let placeholder = L10n.tr("Localizable", "form.field.password.placeholder", fallback: "Enter password")
        /// Password
        internal static let title = L10n.tr("Localizable", "form.field.password.title", fallback: "Password")
      }
      internal enum Phone {
        /// +7 (___) ___-__-__
        internal static let placeholder = L10n.tr("Localizable", "form.field.phone.placeholder", fallback: "+7 (___) ___-__-__")
        /// Phone
        internal static let title = L10n.tr("Localizable", "form.field.phone.title", fallback: "Phone")
      }
    }
  }
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
    /// TabBar
    internal static let catalog = L10n.tr("Localizable", "tab.catalog", fallback: "Catalog")
    /// Favorites
    internal static let favorites = L10n.tr("Localizable", "tab.favorites", fallback: "Favorites")
    /// Profile
    internal static let profile = L10n.tr("Localizable", "tab.profile", fallback: "Profile")
  }
  internal enum Validation {
    internal enum Comment {
      /// Comment cannot be empty
      internal static let empty = L10n.tr("Localizable", "validation.comment.empty", fallback: "Comment cannot be empty")
      /// Comment is too long (maximum 500 characters)
      internal static let tooLong = L10n.tr("Localizable", "validation.comment.tooLong", fallback: "Comment is too long (maximum 500 characters)")
      /// Comment is too short
      internal static let tooShort = L10n.tr("Localizable", "validation.comment.tooShort", fallback: "Comment is too short")
    }
    internal enum Email {
      /// Enter a valid e-mail
      internal static let invalid = L10n.tr("Localizable", "validation.email.invalid", fallback: "Enter a valid e-mail")
    }
    internal enum Name {
      /// Validation
      internal static let minLength = L10n.tr("Localizable", "validation.name.minLength", fallback: "Name must contain at least 2 characters")
    }
    internal enum Password {
      /// Allowed: latin letters, digits, !@#$%
      internal static let allowedChars = L10n.tr("Localizable", "validation.password.allowedChars", fallback: "Allowed: latin letters, digits, !@#$%")
      /// At least 6 characters
      internal static let minLength = L10n.tr("Localizable", "validation.password.minLength", fallback: "At least 6 characters")
      /// Password must not contain spaces
      internal static let noSpaces = L10n.tr("Localizable", "validation.password.noSpaces", fallback: "Password must not contain spaces")
      /// Add at least one digit
      internal static let requireDigit = L10n.tr("Localizable", "validation.password.requireDigit", fallback: "Add at least one digit")
      /// Add at least one special character (!@#$%)
      internal static let requireSpecial = L10n.tr("Localizable", "validation.password.requireSpecial", fallback: "Add at least one special character (!@#$%)")
      /// Add at least one uppercase letter
      internal static let requireUppercase = L10n.tr("Localizable", "validation.password.requireUppercase", fallback: "Add at least one uppercase letter")
    }
    internal enum Phone {
      /// Enter a phone number in the format +7 (XXX) XXX-XX-XX
      internal static let invalidFormat = L10n.tr("Localizable", "validation.phone.invalidFormat", fallback: "Enter a phone number in the format +7 (XXX) XXX-XX-XX")
    }
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
