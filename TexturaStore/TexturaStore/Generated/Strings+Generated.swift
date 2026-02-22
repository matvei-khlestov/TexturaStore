// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum About {
    /// About
    internal static var intro: String {
      return L10n.tr("Localizable", "about.intro", fallback: "Textura Store is an online store of fabrics and interior materials, created for those who value quality, style, and thoughtful details. We help bring ideas to life — from cozy home spaces to professional design projects.")
    }
    internal enum Bullet {
      internal enum Client {
        /// We are always ready to help with selection, answer questions, and make the purchasing process simple and convenient.
        internal static var subtitle: String {
          return L10n.tr("Localizable", "about.bullet.client.subtitle", fallback: "We are always ready to help with selection, answer questions, and make the purchasing process simple and convenient.")
        }
        /// Customer focus
        internal static var title: String {
          return L10n.tr("Localizable", "about.bullet.client.title", fallback: "Customer focus")
        }
      }
      internal enum Design {
        /// We follow trends in textiles and interior design, regularly updating collections and offering modern solutions.
        internal static var subtitle: String {
          return L10n.tr("Localizable", "about.bullet.design.subtitle", fallback: "We follow trends in textiles and interior design, regularly updating collections and offering modern solutions.")
        }
        /// Contemporary design
        internal static var title: String {
          return L10n.tr("Localizable", "about.bullet.design.title", fallback: "Contemporary design")
        }
      }
      internal enum Quality {
        /// We carefully select fabrics and suppliers so that every item in the catalog meets high standards of quality and durability.
        internal static var subtitle: String {
          return L10n.tr("Localizable", "about.bullet.quality.subtitle", fallback: "We carefully select fabrics and suppliers so that every item in the catalog meets high standards of quality and durability.")
        }
        /// Material quality
        internal static var title: String {
          return L10n.tr("Localizable", "about.bullet.quality.title", fallback: "Material quality")
        }
      }
      internal enum Range {
        /// The assortment includes fabrics of various textures, colors, and purposes — for home, office, and commercial spaces.
        internal static var subtitle: String {
          return L10n.tr("Localizable", "about.bullet.range.subtitle", fallback: "The assortment includes fabrics of various textures, colors, and purposes — for home, office, and commercial spaces.")
        }
        /// Wide selection
        internal static var title: String {
          return L10n.tr("Localizable", "about.bullet.range.title", fallback: "Wide selection")
        }
      }
    }
  }
  internal enum Auth {
    internal enum Reset {
      /// Back to Sign In
      internal static var backRowAction: String {
        return L10n.tr("Localizable", "auth.reset.backRowAction", fallback: "Back to Sign In")
      }
      /// Remembered your password?
      internal static var backRowLabel: String {
        return L10n.tr("Localizable", "auth.reset.backRowLabel", fallback: "Remembered your password?")
      }
      /// Send
      internal static var submit: String {
        return L10n.tr("Localizable", "auth.reset.submit", fallback: "Send")
      }
      /// Enter your e-mail and we will send a password reset link.
      internal static var subtitle: String {
        return L10n.tr("Localizable", "auth.reset.subtitle", fallback: "Enter your e-mail and we will send a password reset link.")
      }
      /// Auth - Reset Password
      internal static var title: String {
        return L10n.tr("Localizable", "auth.reset.title", fallback: "Password reset")
      }
      internal enum Alert {
        internal enum Done {
          /// We sent you an email. Check your inbox.
          internal static var message: String {
            return L10n.tr("Localizable", "auth.reset.alert.done.message", fallback: "We sent you an email. Check your inbox.")
          }
          /// Done
          internal static var title: String {
            return L10n.tr("Localizable", "auth.reset.alert.done.title", fallback: "Done")
          }
        }
      }
    }
    internal enum Root {
      internal enum Signin {
        /// Auth - Root
        internal static var title: String {
          return L10n.tr("Localizable", "auth.root.signin.title", fallback: "Sign In")
        }
      }
      internal enum Signup {
        /// Sign Up
        internal static var title: String {
          return L10n.tr("Localizable", "auth.root.signup.title", fallback: "Sign Up")
        }
      }
    }
    internal enum Signin {
      /// Auth - Sign In
      internal static var forgotPassword: String {
        return L10n.tr("Localizable", "auth.signin.forgotPassword", fallback: "Forgot password?")
      }
      /// Sign Up
      internal static var noteAction: String {
        return L10n.tr("Localizable", "auth.signin.noteAction", fallback: "Sign Up")
      }
      /// Don't have an account?
      internal static var noteText: String {
        return L10n.tr("Localizable", "auth.signin.noteText", fallback: "Don't have an account?")
      }
      /// Sign In
      internal static var submit: String {
        return L10n.tr("Localizable", "auth.signin.submit", fallback: "Sign In")
      }
    }
    internal enum Signup {
      /// Sign In
      internal static var noteAction: String {
        return L10n.tr("Localizable", "auth.signup.noteAction", fallback: "Sign In")
      }
      /// Already have an account?
      internal static var noteText: String {
        return L10n.tr("Localizable", "auth.signup.noteText", fallback: "Already have an account?")
      }
      /// Auth - Sign Up
      internal static var privacyTitle: String {
        return L10n.tr("Localizable", "auth.signup.privacyTitle", fallback: "Privacy Policy")
      }
      /// Sign Up
      internal static var submit: String {
        return L10n.tr("Localizable", "auth.signup.submit", fallback: "Sign Up")
      }
      internal enum Agreement {
        /// You must agree to the privacy policy
        internal static var error: String {
          return L10n.tr("Localizable", "auth.signup.agreement.error", fallback: "You must agree to the privacy policy")
        }
      }
      internal enum Success {
        /// We sent an email to confirm your email address.
        /// 
        /// Confirm your email and sign in to the app.
        /// 
        /// You will be redirected to the Sign In screen.
        internal static var message: String {
          return L10n.tr("Localizable", "auth.signup.success.message", fallback: "We sent an email to confirm your email address.\n\nConfirm your email and sign in to the app.\n\nYou will be redirected to the Sign In screen.")
        }
        /// Registration successful
        internal static var title: String {
          return L10n.tr("Localizable", "auth.signup.success.title", fallback: "Registration successful")
        }
      }
    }
  }
  internal enum Cart {
    /// Your cart is empty
    internal static var emptyState: String {
      return L10n.tr("Localizable", "cart.emptyState", fallback: "Your cart is empty")
    }
    internal enum Checkout {
      /// Checkout
      internal static var title: String {
        return L10n.tr("Localizable", "cart.checkout.title", fallback: "Checkout")
      }
    }
    internal enum Clear {
      /// Clear
      internal static var title: String {
        return L10n.tr("Localizable", "cart.clear.title", fallback: "Clear")
      }
      internal enum Confirm {
        /// Clear cart?
        internal static var title: String {
          return L10n.tr("Localizable", "cart.clear.confirm.title", fallback: "Clear cart?")
        }
      }
    }
    internal enum Navigation {
      /// CartView
      internal static var title: String {
        return L10n.tr("Localizable", "cart.navigation.title", fallback: "Cart")
      }
    }
    internal enum Swipe {
      /// Delete
      internal static var delete: String {
        return L10n.tr("Localizable", "cart.swipe.delete", fallback: "Delete")
      }
    }
  }
  internal enum Catalog {
    internal enum Category {
      internal enum Products {
        /// %d products
        internal static func count(_ p1: Int) -> String {
          return L10n.tr("Localizable", "catalog.category.products.count", p1, fallback: "%d products")
        }
      }
    }
    internal enum Filters {
      /// Filters
      internal static var title: String {
        return L10n.tr("Localizable", "catalog.filters.title", fallback: "Filters")
      }
    }
    internal enum Navigation {
      /// CatalogView
      internal static var title: String {
        return L10n.tr("Localizable", "catalog.navigation.title", fallback: "Catalog")
      }
    }
    internal enum Product {
      internal enum Cart {
        /// Add to cart
        internal static var add: String {
          return L10n.tr("Localizable", "catalog.product.cart.add", fallback: "Add to cart")
        }
        /// In cart
        internal static var `in`: String {
          return L10n.tr("Localizable", "catalog.product.cart.in", fallback: "In cart")
        }
      }
      internal enum Favorite {
        /// Add to favorites
        internal static var add: String {
          return L10n.tr("Localizable", "catalog.product.favorite.add", fallback: "Add to favorites")
        }
        /// Remove from favorites
        internal static var remove: String {
          return L10n.tr("Localizable", "catalog.product.favorite.remove", fallback: "Remove from favorites")
        }
      }
    }
    internal enum Products {
      /// All products
      internal static var title: String {
        return L10n.tr("Localizable", "catalog.products.title", fallback: "All products")
      }
    }
    internal enum Search {
      /// Furniture search
      internal static var placeholder: String {
        return L10n.tr("Localizable", "catalog.search.placeholder", fallback: "Furniture search")
      }
    }
  }
  internal enum Common {
    /// OK
    internal static var ok: String {
      return L10n.tr("Localizable", "common.ok", fallback: "OK")
    }
    internal enum Error {
      /// Common
      internal static var title: String {
        return L10n.tr("Localizable", "common.error.title", fallback: "Error")
      }
    }
  }
  internal enum Contact {
    /// Copy
    internal static var copy: String {
      return L10n.tr("Localizable", "contact.copy", fallback: "Copy")
    }
    /// Contact Us
    internal static var title: String {
      return L10n.tr("Localizable", "contact.title", fallback: "Contact Us")
    }
    internal enum Email {
      internal enum Copied {
        /// Address copied to clipboard:
        /// 
        internal static var `prefix`: String {
          return L10n.tr("Localizable", "contact.email.copied.prefix", fallback: "Address copied to clipboard:\n")
        }
      }
      internal enum OpenFailed {
        /// Unable to open Mail
        internal static var title: String {
          return L10n.tr("Localizable", "contact.email.openFailed.title", fallback: "Unable to open Mail")
        }
      }
    }
    internal enum Item {
      internal enum Address {
        /// Moscow, Khodynsky Boulevard, 4
        internal static var detail: String {
          return L10n.tr("Localizable", "contact.item.address.detail", fallback: "Moscow, Khodynsky Boulevard, 4")
        }
        /// Address
        internal static var title: String {
          return L10n.tr("Localizable", "contact.item.address.title", fallback: "Address")
        }
      }
      internal enum Email {
        /// support@vemora.ru
        internal static var detail: String {
          return L10n.tr("Localizable", "contact.item.email.detail", fallback: "support@vemora.ru")
        }
        /// Email
        internal static var title: String {
          return L10n.tr("Localizable", "contact.item.email.title", fallback: "Email")
        }
      }
      internal enum Phone {
        /// +7 (800) 555-35-35
        internal static var detail: String {
          return L10n.tr("Localizable", "contact.item.phone.detail", fallback: "+7 (800) 555-35-35")
        }
        /// Contact Items
        internal static var title: String {
          return L10n.tr("Localizable", "contact.item.phone.title", fallback: "Phone")
        }
      }
    }
    internal enum Phone {
      internal enum Copied {
        /// Number copied to clipboard:
        /// 
        internal static var `prefix`: String {
          return L10n.tr("Localizable", "contact.phone.copied.prefix", fallback: "Number copied to clipboard:\n")
        }
      }
      internal enum Unavailable {
        /// Call unavailable
        internal static var title: String {
          return L10n.tr("Localizable", "contact.phone.unavailable.title", fallback: "Call unavailable")
        }
      }
    }
    internal enum Url {
      internal enum OpenFailed {
        /// Unable to open link
        internal static var title: String {
          return L10n.tr("Localizable", "contact.url.openFailed.title", fallback: "Unable to open link")
        }
      }
    }
  }
  internal enum Favorites {
    /// No favorites yet
    internal static var emptyState: String {
      return L10n.tr("Localizable", "favorites.emptyState", fallback: "No favorites yet")
    }
    internal enum Cart {
      /// Add to cart
      internal static var add: String {
        return L10n.tr("Localizable", "favorites.cart.add", fallback: "Add to cart")
      }
      /// In cart
      internal static var `in`: String {
        return L10n.tr("Localizable", "favorites.cart.in", fallback: "In cart")
      }
    }
    internal enum Clear {
      /// Clear
      internal static var title: String {
        return L10n.tr("Localizable", "favorites.clear.title", fallback: "Clear")
      }
      internal enum Confirm {
        /// Clear favorites?
        internal static var title: String {
          return L10n.tr("Localizable", "favorites.clear.confirm.title", fallback: "Clear favorites?")
        }
      }
    }
    internal enum Navigation {
      /// FavoritesView
      internal static var title: String {
        return L10n.tr("Localizable", "favorites.navigation.title", fallback: "Favorites")
      }
    }
    internal enum Swipe {
      /// Delete
      internal static var delete: String {
        return L10n.tr("Localizable", "favorites.swipe.delete", fallback: "Delete")
      }
    }
  }
  internal enum Form {
    internal enum Field {
      internal enum Email {
        /// Enter e-mail
        internal static var placeholder: String {
          return L10n.tr("Localizable", "form.field.email.placeholder", fallback: "Enter e-mail")
        }
        /// E-mail
        internal static var title: String {
          return L10n.tr("Localizable", "form.field.email.title", fallback: "E-mail")
        }
      }
      internal enum Name {
        /// Enter name
        internal static var placeholder: String {
          return L10n.tr("Localizable", "form.field.name.placeholder", fallback: "Enter name")
        }
        /// Form - Fields
        internal static var title: String {
          return L10n.tr("Localizable", "form.field.name.title", fallback: "Name")
        }
      }
      internal enum Password {
        /// Enter password
        internal static var placeholder: String {
          return L10n.tr("Localizable", "form.field.password.placeholder", fallback: "Enter password")
        }
        /// Password
        internal static var title: String {
          return L10n.tr("Localizable", "form.field.password.title", fallback: "Password")
        }
      }
      internal enum Phone {
        /// +7 (___) ___-__-__
        internal static var placeholder: String {
          return L10n.tr("Localizable", "form.field.phone.placeholder", fallback: "+7 (___) ___-__-__")
        }
        /// Phone
        internal static var title: String {
          return L10n.tr("Localizable", "form.field.phone.title", fallback: "Phone")
        }
      }
    }
  }
  internal enum PrivacyPolicy {
    /// Updated: September 17, 2025
    /// 
    /// 1. General provisions
    /// Textura respects your personal data and processes it in accordance with applicable laws and internal security standards. This Policy describes what data we collect, how we use and protect it.
    /// 
    /// 2. What data we collect
    /// • Contact data: name, phone, e-mail.
    /// • Delivery data: city, street, building, apartment, postal code (if any), delivery comment.
    /// • Order data: order contents (products/fabrics, length, characteristics), cost, payment/delivery method, purchase history.
    /// • Technical data: device, OS version, IP address, session/device identifiers, diagnostic data and app usage analytics.
    /// 
    /// 3. Purposes of processing
    /// • Order placement, processing and delivery (including confirmation and status notifications).
    /// • User support and request handling.
    /// • Improving service quality, catalog personalization and recommendations.
    /// • Compliance with legal requirements (accounting and taxes, refunds, etc.).
    /// 
    /// 4. Legal bases
    /// • Contract performance (order placement, delivery, returns).
    /// • User consent (e.g. marketing messages — if enabled).
    /// • Legitimate interests (service security and fraud prevention).
    /// • Legal obligations (tax/financial requirements).
    /// 
    /// 5. Transfer to third parties
    /// We may transfer data to:
    /// • Delivery and logistics partners — to fulfill delivery and communicate about the order.
    /// • Payment providers — to accept payments and process refunds.
    /// • IT infrastructure and analytics providers — hosting, monitoring, crash diagnostics and stability improvements.
    /// Transfers are carried out under agreements with data protection obligations.
    /// 
    /// 6. Storage and protection
    /// • Data is stored as long as necessary for the purposes of processing and within time limits established by law.
    /// • We apply technical and organizational security measures, including encryption, access control and audits.
    /// 
    /// 7. User rights
    /// You can:
    /// • Request access to your data and receive a copy.
    /// • Correct inaccurate information.
    /// • Restrict processing or object to it.
    /// • Withdraw consent (does not affect lawfulness before withdrawal).
    /// • Request deletion of data if permitted by law.
    /// 
    /// 8. Cookies, identifiers and analytics
    /// We use cookies/identifiers and analytics to ensure the app works properly, enable authorization, improve the UI and service quality. You can manage these settings in the system/device, however this may affect functionality.
    /// 
    /// 9. Contact us
    /// For privacy matters:
    /// • E-mail: privacy@textura.ru
    /// • Phone: +7 (800) 555-35-35
    /// • Address: Moscow, Example street, 1
    /// 
    /// 10. Policy changes
    /// We may periodically update the Policy. The new version comes into force from the moment it is published in the app. We recommend checking the update date periodically.
    /// 
    /// —
    /// Textura
    internal static var body: String {
      return L10n.tr("Localizable", "privacyPolicy.body", fallback: "Updated: September 17, 2025\n\n1. General provisions\nTextura respects your personal data and processes it in accordance with applicable laws and internal security standards. This Policy describes what data we collect, how we use and protect it.\n\n2. What data we collect\n• Contact data: name, phone, e-mail.\n• Delivery data: city, street, building, apartment, postal code (if any), delivery comment.\n• Order data: order contents (products/fabrics, length, characteristics), cost, payment/delivery method, purchase history.\n• Technical data: device, OS version, IP address, session/device identifiers, diagnostic data and app usage analytics.\n\n3. Purposes of processing\n• Order placement, processing and delivery (including confirmation and status notifications).\n• User support and request handling.\n• Improving service quality, catalog personalization and recommendations.\n• Compliance with legal requirements (accounting and taxes, refunds, etc.).\n\n4. Legal bases\n• Contract performance (order placement, delivery, returns).\n• User consent (e.g. marketing messages — if enabled).\n• Legitimate interests (service security and fraud prevention).\n• Legal obligations (tax/financial requirements).\n\n5. Transfer to third parties\nWe may transfer data to:\n• Delivery and logistics partners — to fulfill delivery and communicate about the order.\n• Payment providers — to accept payments and process refunds.\n• IT infrastructure and analytics providers — hosting, monitoring, crash diagnostics and stability improvements.\nTransfers are carried out under agreements with data protection obligations.\n\n6. Storage and protection\n• Data is stored as long as necessary for the purposes of processing and within time limits established by law.\n• We apply technical and organizational security measures, including encryption, access control and audits.\n\n7. User rights\nYou can:\n• Request access to your data and receive a copy.\n• Correct inaccurate information.\n• Restrict processing or object to it.\n• Withdraw consent (does not affect lawfulness before withdrawal).\n• Request deletion of data if permitted by law.\n\n8. Cookies, identifiers and analytics\nWe use cookies/identifiers and analytics to ensure the app works properly, enable authorization, improve the UI and service quality. You can manage these settings in the system/device, however this may affect functionality.\n\n9. Contact us\nFor privacy matters:\n• E-mail: privacy@textura.ru\n• Phone: +7 (800) 555-35-35\n• Address: Moscow, Example street, 1\n\n10. Policy changes\nWe may periodically update the Policy. The new version comes into force from the moment it is published in the app. We recommend checking the update date periodically.\n\n—\nTextura")
    }
    /// Privacy Policy
    internal static var lastUpdated: String {
      return L10n.tr("Localizable", "privacyPolicy.lastUpdated", fallback: "Updated: September 17, 2025")
    }
  }
  internal enum Profile {
    internal enum Delete {
      /// Delete your account?
      internal static var confirm: String {
        return L10n.tr("Localizable", "profile.delete.confirm", fallback: "Delete your account?")
      }
      /// Delete Account
      internal static var title: String {
        return L10n.tr("Localizable", "profile.delete.title", fallback: "Delete Account")
      }
    }
    internal enum Edit {
      /// Change photo
      internal static var changePhoto: String {
        return L10n.tr("Localizable", "profile.edit.changePhoto", fallback: "Change photo")
      }
      /// Profile - Edit Screen
      internal static var title: String {
        return L10n.tr("Localizable", "profile.edit.title", fallback: "Edit Profile")
      }
      internal enum PhotoPicker {
        /// Invalid image object.
        internal static var invalidImageObject: String {
          return L10n.tr("Localizable", "profile.edit.photoPicker.invalidImageObject", fallback: "Invalid image object.")
        }
        /// Profile - Edit - PhotoPicker
        internal static var unableToLoadImage: String {
          return L10n.tr("Localizable", "profile.edit.photoPicker.unableToLoadImage", fallback: "Unable to load image.")
        }
      }
      internal enum Row {
        /// E-mail
        internal static var email: String {
          return L10n.tr("Localizable", "profile.edit.row.email", fallback: "E-mail")
        }
        /// Profile - Edit
        internal static var name: String {
          return L10n.tr("Localizable", "profile.edit.row.name", fallback: "Name")
        }
        /// Phone
        internal static var phone: String {
          return L10n.tr("Localizable", "profile.edit.row.phone", fallback: "Phone")
        }
      }
    }
    internal enum EditEmail {
      /// Change e-mail
      internal static var title: String {
        return L10n.tr("Localizable", "profile.editEmail.title", fallback: "Change e-mail")
      }
    }
    internal enum EditField {
      /// Profile - Edit Field (BaseEditFieldView)
      internal static var submit: String {
        return L10n.tr("Localizable", "profile.editField.submit", fallback: "Change")
      }
      internal enum Email {
        internal enum Success {
          /// We sent an email to confirm changing your e-mail to both your old and new address.
          internal static var message: String {
            return L10n.tr("Localizable", "profile.editField.email.success.message", fallback: "We sent an email to confirm changing your e-mail to both your old and new address.")
          }
          /// Check your email
          internal static var title: String {
            return L10n.tr("Localizable", "profile.editField.email.success.title", fallback: "Check your email")
          }
        }
      }
      internal enum Name {
        internal enum Success {
          /// Name successfully changed.
          internal static var message: String {
            return L10n.tr("Localizable", "profile.editField.name.success.message", fallback: "Name successfully changed.")
          }
          /// Done
          internal static var title: String {
            return L10n.tr("Localizable", "profile.editField.name.success.title", fallback: "Done")
          }
        }
      }
      internal enum Phone {
        internal enum Success {
          /// Phone number successfully changed.
          internal static var message: String {
            return L10n.tr("Localizable", "profile.editField.phone.success.message", fallback: "Phone number successfully changed.")
          }
          /// Done
          internal static var title: String {
            return L10n.tr("Localizable", "profile.editField.phone.success.title", fallback: "Done")
          }
        }
      }
    }
    internal enum EditName {
      /// Profile - Edit Field Screens
      internal static var title: String {
        return L10n.tr("Localizable", "profile.editName.title", fallback: "Change name")
      }
    }
    internal enum EditPhone {
      /// Change phone number
      internal static var title: String {
        return L10n.tr("Localizable", "profile.editPhone.title", fallback: "Change phone number")
      }
    }
    internal enum Error {
      /// Unknown error
      internal static var unknown: String {
        return L10n.tr("Localizable", "profile.error.unknown", fallback: "Unknown error")
      }
    }
    internal enum Logout {
      /// Log out of your account?
      internal static var confirm: String {
        return L10n.tr("Localizable", "profile.logout.confirm", fallback: "Log out of your account?")
      }
      /// Profile
      internal static var title: String {
        return L10n.tr("Localizable", "profile.logout.title", fallback: "Log Out")
      }
    }
    internal enum Menu {
      /// About Us
      internal static var about: String {
        return L10n.tr("Localizable", "profile.menu.about", fallback: "About Us")
      }
      /// Contact Us
      internal static var contact: String {
        return L10n.tr("Localizable", "profile.menu.contact", fallback: "Contact Us")
      }
      /// Profile - Menu
      internal static var editProfile: String {
        return L10n.tr("Localizable", "profile.menu.editProfile", fallback: "Edit Profile")
      }
      /// My Orders
      internal static var orders: String {
        return L10n.tr("Localizable", "profile.menu.orders", fallback: "My Orders")
      }
      /// Privacy Policy
      internal static var privacy: String {
        return L10n.tr("Localizable", "profile.menu.privacy", fallback: "Privacy Policy")
      }
      /// Settings
      internal static var settings: String {
        return L10n.tr("Localizable", "profile.menu.settings", fallback: "Settings")
      }
    }
  }
  internal enum Screen {
    internal enum Cart {
      /// Cart
      internal static var title: String {
        return L10n.tr("Localizable", "screen.cart.title", fallback: "Cart")
      }
    }
    internal enum Catalog {
      /// Catalog
      internal static var title: String {
        return L10n.tr("Localizable", "screen.catalog.title", fallback: "Catalog")
      }
    }
    internal enum Favorites {
      /// Favorites
      internal static var title: String {
        return L10n.tr("Localizable", "screen.favorites.title", fallback: "Favorites")
      }
    }
    internal enum Profile {
      /// Profile
      internal static var title: String {
        return L10n.tr("Localizable", "screen.profile.title", fallback: "Profile")
      }
    }
  }
  internal enum Settings {
    /// Settings
    internal static var title: String {
      return L10n.tr("Localizable", "settings.title", fallback: "Settings")
    }
    internal enum Language {
      /// English
      internal static var en: String {
        return L10n.tr("Localizable", "settings.language.en", fallback: "English")
      }
      /// Choose the app interface language.
      internal static var footer: String {
        return L10n.tr("Localizable", "settings.language.footer", fallback: "Choose the app interface language.")
      }
      /// Language
      internal static var header: String {
        return L10n.tr("Localizable", "settings.language.header", fallback: "Language")
      }
      /// Russian
      internal static var ru: String {
        return L10n.tr("Localizable", "settings.language.ru", fallback: "Russian")
      }
    }
    internal enum Theme {
      /// Dark
      internal static var dark: String {
        return L10n.tr("Localizable", "settings.theme.dark", fallback: "Dark")
      }
      /// Choose the app appearance.
      internal static var footer: String {
        return L10n.tr("Localizable", "settings.theme.footer", fallback: "Choose the app appearance.")
      }
      /// Theme
      internal static var header: String {
        return L10n.tr("Localizable", "settings.theme.header", fallback: "Theme")
      }
      /// Light
      internal static var light: String {
        return L10n.tr("Localizable", "settings.theme.light", fallback: "Light")
      }
      /// System
      internal static var system: String {
        return L10n.tr("Localizable", "settings.theme.system", fallback: "System")
      }
    }
  }
  internal enum Tab {
    /// Cart
    internal static var cart: String {
      return L10n.tr("Localizable", "tab.cart", fallback: "Cart")
    }
    /// TabBar
    internal static var catalog: String {
      return L10n.tr("Localizable", "tab.catalog", fallback: "Catalog")
    }
    /// Favorites
    internal static var favorites: String {
      return L10n.tr("Localizable", "tab.favorites", fallback: "Favorites")
    }
    /// Profile
    internal static var profile: String {
      return L10n.tr("Localizable", "tab.profile", fallback: "Profile")
    }
  }
  internal enum Validation {
    internal enum Comment {
      /// Comment cannot be empty
      internal static var empty: String {
        return L10n.tr("Localizable", "validation.comment.empty", fallback: "Comment cannot be empty")
      }
      /// Comment is too long (maximum 500 characters)
      internal static var tooLong: String {
        return L10n.tr("Localizable", "validation.comment.tooLong", fallback: "Comment is too long (maximum 500 characters)")
      }
      /// Comment is too short
      internal static var tooShort: String {
        return L10n.tr("Localizable", "validation.comment.tooShort", fallback: "Comment is too short")
      }
    }
    internal enum Email {
      /// Enter a valid e-mail
      internal static var invalid: String {
        return L10n.tr("Localizable", "validation.email.invalid", fallback: "Enter a valid e-mail")
      }
    }
    internal enum Name {
      /// Validation
      internal static var minLength: String {
        return L10n.tr("Localizable", "validation.name.minLength", fallback: "Name must contain at least 2 characters")
      }
    }
    internal enum Password {
      /// Allowed: latin letters, digits, !@#$%
      internal static var allowedChars: String {
        return L10n.tr("Localizable", "validation.password.allowedChars", fallback: "Allowed: latin letters, digits, !@#$%")
      }
      /// At least 6 characters
      internal static var minLength: String {
        return L10n.tr("Localizable", "validation.password.minLength", fallback: "At least 6 characters")
      }
      /// Password must not contain spaces
      internal static var noSpaces: String {
        return L10n.tr("Localizable", "validation.password.noSpaces", fallback: "Password must not contain spaces")
      }
      /// Add at least one digit
      internal static var requireDigit: String {
        return L10n.tr("Localizable", "validation.password.requireDigit", fallback: "Add at least one digit")
      }
      /// Add at least one special character (!@#$%)
      internal static var requireSpecial: String {
        return L10n.tr("Localizable", "validation.password.requireSpecial", fallback: "Add at least one special character (!@#$%)")
      }
      /// Add at least one uppercase letter
      internal static var requireUppercase: String {
        return L10n.tr("Localizable", "validation.password.requireUppercase", fallback: "Add at least one uppercase letter")
      }
    }
    internal enum Phone {
      /// Enter a phone number in the format +7 (XXX) XXX-XX-XX
      internal static var invalidFormat: String {
        return L10n.tr("Localizable", "validation.phone.invalidFormat", fallback: "Enter a phone number in the format +7 (XXX) XXX-XX-XX")
      }
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
