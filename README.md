# TexturaStore

<img width="2565" height="6022" alt="Frame" src="https://github.com/user-attachments/assets/9ff89f8c-52ee-4210-b214-6fbd3852cb44" />

## Overview

TexturaStore is an iOS application that represents a modern mobile e-commerce solution for a fabric and interior materials store.

The project was developed as part of a diploma work and demonstrates practical approaches to building scalable, maintainable, and user-friendly mobile applications using modern iOS technologies.

The application focuses on delivering a full user journey — from browsing products to placing orders — while maintaining clean architecture and high code quality.

## Project Goals

- Develop a full-featured mobile e-commerce application
- Apply MVVM + Coordinator architecture in a real-world scenario
- Integrate remote backend services (Supabase)
- Implement a scalable and maintainable project structure
- Ensure high-quality UX and responsiveness
- Demonstrate modern iOS development practices

## Key Features

- User registration and authentication (Supabase Auth)
- Password reset functionality
- Product catalog with categories, brands, and filters
- Product details with descriptions, ratings, and reviews
- Search functionality by product name
- Favorites management
- Cart management
- Order placement (pickup or delivery)
- Order history ("My Orders")
- User profile management (edit and delete account)
- Local notifications support
- Light / Dark / System theme switching
- Multi-language support (Russian / English)
- Informational sections: About, Contacts, Privacy Policy
- Product ratings and user reviews (1–5 stars)

## Architecture

The application is built using the **MVVM** pattern combined with the **Coordinator** pattern.

Key architectural principles:

- Views are responsible only for UI rendering
- ViewModels contain business logic and state management
- Coordinators handle navigation and flow control
- Repositories abstract data access
- Services encapsulate reusable logic
- Dependency Injection is centralized via Factory

This architecture provides:

- Clear separation of concerns
- High scalability
- Improved testability
- Maintainable and modular codebase

## Tech Stack

- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Platform:** iOS 15+
- **Language:** Swift

### UI
- **SwiftUI** (main UI layer)
- **UIKit** (integration with system components)

### Architecture & Patterns
- **MVVM + Coordinator**
- **Dependency Injection (Factory)**

### Networking & Data
- **URLSession**
- **Core Data (SQLite)** — local storage
- **Keychain** — secure data storage
- **UserDefaults** — preferences storage
- **FileManager** — local file storage

### Concurrency & Reactivity
- **Async / Await**
- **Combine**

### Tools & Infrastructure
- **Git / GitHub**
- **Swift Package Manager (SPM)**

### Additional
- **Firebase Analytics**
- **SwiftGen (localization)**
- **UserNotifications (local notifications)**

## Data Storage

- **Supabase** is used as the main backend:
  - Authentication
  - Database (PostgreSQL)
  - File storage (images)

- **Core Data** is used for:
  - Local caching
  - Offline support

- **Keychain** stores:
  - Tokens and sensitive user data

- **UserDefaults** stores:
  - App settings (theme, language)

## Project Scope

The project covers the full user journey of an e-commerce application:

- Authentication and onboarding
- Catalog browsing and filtering
- Product details and reviews
- Cart and checkout flow
- Order history
- Profile management

This makes the application close to a real production-level product in terms of architecture and functionality.

## Testing

The project includes unit testing:

- **Unit tests** validate:
  - ViewModels
  - Business logic
  - Services and repositories

The chosen architecture (MVVM + Coordinator + DI) allows easy isolation of components and simplifies testing.

## Notes

This project is created for **educational and demonstration purposes**.

The main focus is:

- Clean architecture
- Code quality
- Real-world application structure

rather than production deployment.

## License

This project is provided for educational use only.
