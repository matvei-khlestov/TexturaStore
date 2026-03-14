//
//  Container+ViewModels.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import FactoryKit

extension Container {
    
    // MARK: - Auth
    
    var signInViewModel: Factory<any SignInViewModelProtocol> {
        Factory(self) { @MainActor in
            SignInViewModel(
                validator: self.formValidator(),
                authService: self.authService(),
                makeProfileRepository: self.makeProfileRepository
            )
        }
        .scope(.shared)
    }
    
    var signUpViewModel: Factory<any SignUpViewModelProtocol> {
        Factory(self) { @MainActor in
            SignUpViewModel(
                validator: self.formValidator(),
                authService: self.authService()
            )
        }
        .scope(.singleton)
    }
    
    var resetPasswordViewModel: Factory<any ResetPasswordViewModelProtocol> {
        Factory(self) { @MainActor in
            ResetPasswordViewModel(
                validator: self.formValidator(),
                passwordResetService: self.passwordResetService()
            )
        }
        .scope(.shared)
    }
    
    // MARK: - Profile
    
    var profileViewModel: Factory<(String) -> any ProfileUserViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                ProfileUserViewModel(
                    auth: self.authService(),
                    avatarStorage: self.avatarStorageService(),
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId
                )
            }
        }
    }
    
    var editProfileViewModel: Factory<(String) -> any EditProfileViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditProfileViewModel(
                    avatarStorage: self.avatarStorageService(),
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId,
                    checkoutStorage: self.checkoutStorage()
                )
            }
        }
        .scope(.shared)
    }
    
    var editNameViewModel: Factory<(String) -> any EditNameViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditNameViewModel(
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId,
                    validator: self.formValidator()
                )
            }
        }
        .scope(.shared)
    }
    
    var editEmailViewModel: Factory<(String) -> any EditEmailViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditEmailViewModel(
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId,
                    validator: self.formValidator()
                )
            }
        }
        .scope(.shared)
    }
    
    var editPhoneViewModel: Factory<(String) -> any EditPhoneViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditPhoneViewModel(
                    profileRepository: self.makeProfileRepository(userId),
                    validator: self.formValidator(),
                    userId: userId
                )
            }
        }
        .scope(.shared)
    }
    
    // MARK: - Settings
    
    var settingsViewModel: Factory<any SettingsViewModelProtocol> {
        Factory(self) { @MainActor in
            SettingsViewModel(
                service: self.settingsService()
            )
        }
        .scope(.shared)
    }
    
    // MARK: - Catalog
    
    var makeCatalogViewModel: Factory<(String) -> any CatalogViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                CatalogViewModel(
                    repository: self.catalogRepository(),
                    cartRepository: self.makeCartRepository(userId),
                    favoritesRepository: self.makeFavoritesRepository(userId),
                    priceFormatter: self.priceFormatter()
                )
            }
        }
    }
    
    // MARK: - Catalog filter
    
    var catalogFilterViewModel: Factory<any CatalogFilterViewModelProtocol> {
        Factory(self) { @MainActor in
            CatalogFilterViewModel(
                repository: self.catalogRepository()
            )
        }
        .scope(.shared)
    }
    
    // MARK: - Category products
    
    var makeCategoryProductsViewModel: Factory<(String, String) -> any CategoryProductsViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId, categoryId in
                CategoryProductsViewModel(
                    categoryId: categoryId,
                    repository: self.catalogRepository(),
                    cartRepository: self.makeCartRepository(userId),
                    favoritesRepository: self.makeFavoritesRepository(userId),
                    priceFormatter: self.priceFormatter()
                )
            }
        }
    }
    
    // MARK: - Product details
    
    var makeProductDetailsViewModel: Factory<(String, String) -> any ProductDetailsViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId, productId in
                ProductDetailsViewModel(
                    productId: productId,
                    currentUserId: userId,
                    favoritesRepository: self.makeFavoritesRepository(userId),
                    cartRepository: self.makeCartRepository(userId),
                    catalogRepository: self.catalogRepository(),
                    reviewsRepository: self.makeReviewsRepository(productId),
                    priceFormatter: self.priceFormatter()
                )
            }
        }
    }
    
    // MARK: - Favorites
    
    var makeFavoritesViewModel: Factory<(String) -> any FavoritesViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                FavoritesViewModel(
                    favoritesRepository: self.makeFavoritesRepository(userId),
                    cartRepository: self.makeCartRepository(userId),
                    priceFormatter: self.priceFormatter(),
                    notificationService: self.localNotificationService()
                )
            }
        }
    }
    
    // MARK: - Cart
    
    var makeCartViewModel: Factory<(String) -> any CartViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                CartViewModel(
                    cartRepository: self.makeCartRepository(userId),
                    priceFormatter: self.priceFormatter(),
                    notificationService: self.localNotificationService()
                )
            }
        }
    }
    
    // MARK: - Checkout
    
    var makeCheckoutViewModel: Factory<(String, [CartItem]) -> any CheckoutViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId, snapshotItems in
                CheckoutViewModel(
                    cartRepository: self.makeCartRepository(userId),
                    ordersRepository: self.makeOrdersRepository(userId),
                    phoneFormatter: self.phoneFormatter(),
                    priceFormatter: self.priceFormatter(),
                    snapshotItems: snapshotItems,
                    storage: self.checkoutStorage(),
                    currentUserId: userId,
                    notifier: self.localNotificationService()
                )
            }
        }
    }
    
    // MARK: - Checkout sheets
    
    var makeAddressInputSheetViewModel: Factory<(AddressInputSheetValue?) -> any AddressInputSheetViewModelProtocol> {
        Factory(self) { @MainActor in
            { initialAddress in
                AddressInputSheetViewModel(
                    initialAddress: initialAddress
                )
            }
        }
        .scope(.shared)
    }
    
    var makePhoneInputSheetViewModel: Factory<(String?) -> any PhoneInputSheetViewModelProtocol> {
        Factory(self) { @MainActor in
            { initialPhone in
                PhoneInputSheetViewModel(
                    initialPhone: initialPhone,
                    validator: self.formValidator()
                )
            }
        }
        .scope(.shared)
    }
    
    var makeCommentInputSheetViewModel: Factory<(String?) -> any CommentInputSheetViewModelProtocol> {
        Factory(self) { @MainActor in
            { initialComment in
                CommentInputSheetViewModel(
                    initialComment: initialComment,
                    validator: self.formValidator()
                )
            }
        }
        .scope(.shared)
    }
    
    // MARK: - Orders
    
    var makeOrdersViewModel: Factory<(String) -> OrdersViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                OrdersViewModel(
                    repository: self.makeOrdersRepository(userId),
                    priceFormatter: self.priceFormatter()
                )
            }
        }
    }
    
    // MARK: - Reviews
    
    var makeAddReviewViewModel: Factory<(String, String) -> any AddReviewViewModelProtocol> {
        Factory(self) { @MainActor in
            { productId, userId in
                AddReviewViewModel(
                    repository: self.makeReviewsRepository(productId),
                    profileRepository: self.makeProfileRepository(userId),
                    productId: productId,
                    userId: userId,
                    validator: self.formValidator()
                )
            }
        }
    }
    
    var makeReviewsListViewModel: Factory<(String, String) -> any ReviewsListViewModelProtocol> {
        Factory(self) { @MainActor in
            { productId, userId in
                ReviewsListViewModel(
                    reviewsRepository: self.makeReviewsRepository(productId),
                    productId: productId,
                    userId: userId
                )
            }
        }
    }
}
