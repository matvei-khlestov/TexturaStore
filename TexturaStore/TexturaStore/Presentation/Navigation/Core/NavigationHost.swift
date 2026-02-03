//
//  NavigationHost.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

struct NavigationHost<
    StackRoute: RouteIdentifiable,
    SheetRoute: RouteIdentifiable,
    FullScreenRoute: RouteIdentifiable,
    Root: View,
    StackDestination: View,
    SheetDestination: View,
    FullScreenDestination: View
>: View {

    // MARK: - State

    @ObservedObject private var router: AppRouter<StackRoute, SheetRoute, FullScreenRoute>

    // MARK: - Builders

    private let root: () -> Root
    private let stackDestination: (StackRoute) -> StackDestination
    private let sheetDestination: (SheetRoute) -> SheetDestination
    private let fullScreenDestination: (FullScreenRoute) -> FullScreenDestination

    // MARK: - Init

    init(
        router: AppRouter<StackRoute, SheetRoute, FullScreenRoute>,
        @ViewBuilder root: @escaping () -> Root,
        @ViewBuilder stackDestination: @escaping (StackRoute) -> StackDestination,
        @ViewBuilder sheetDestination: @escaping (SheetRoute) -> SheetDestination,
        @ViewBuilder fullScreenDestination: @escaping (FullScreenRoute) -> FullScreenDestination
    ) {
        self.router = router
        self.root = root
        self.stackDestination = stackDestination
        self.sheetDestination = sheetDestination
        self.fullScreenDestination = fullScreenDestination
    }

    // MARK: - Body

    var body: some View {
        content
            .applySheetIfNeeded(router: router, destination: sheetDestination)
            .applyFullScreenIfNeeded(router: router, destination: fullScreenDestination)
    }

    @ViewBuilder
    private var content: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $router.path) {
                root()
                    .navigationDestination(for: StackRoute.self) { route in
                        stackDestination(route)
                    }
            }
        } else {
            NavigationView {
                LegacyNavigationStack(
                    path: $router.path,
                    root: root,
                    destination: stackDestination
                )
            }
            .navigationViewStyle(.stack)
        }
    }
}

// MARK: - Conditional modal modifiers

private extension View {

    @ViewBuilder
    func applySheetIfNeeded<
        StackRoute: RouteIdentifiable,
        SheetRoute: RouteIdentifiable,
        FullScreenRoute: RouteIdentifiable,
        SheetDestination: View
    >(
        router: AppRouter<StackRoute, SheetRoute, FullScreenRoute>,
        @ViewBuilder destination: @escaping (SheetRoute) -> SheetDestination
    ) -> some View {
        if SheetRoute.self == NoRoute.self {
            self
        } else {
            self.sheet(
                item: Binding(
                    get: { router.sheet },
                    set: { router.sheet = $0 }
                )
            ) { route in
                destination(route)
            }
        }
    }

    @ViewBuilder
    func applyFullScreenIfNeeded<
        StackRoute: RouteIdentifiable,
        SheetRoute: RouteIdentifiable,
        FullScreenRoute: RouteIdentifiable,
        FullScreenDestination: View
    >(
        router: AppRouter<StackRoute, SheetRoute, FullScreenRoute>,
        @ViewBuilder destination: @escaping (FullScreenRoute) -> FullScreenDestination
    ) -> some View {
        if FullScreenRoute.self == NoRoute.self {
            self
        } else {
            self.fullScreenCover(
                item: Binding(
                    get: { router.fullScreen },
                    set: { router.fullScreen = $0 }
                )
            ) { route in
                destination(route)
            }
        }
    }
}

// MARK: - iOS 15 stack emulation

private struct LegacyNavigationStack<
    StackRoute: RouteIdentifiable,
    Root: View,
    Destination: View
>: View {

    @Binding var path: [StackRoute]
    let root: () -> Root
    let destination: (StackRoute) -> Destination

    var body: some View {
        ZStack {
            root()
            LegacyPushLink(path: $path, destination: destination)
        }
    }
}

private struct LegacyPushLink<
    StackRoute: RouteIdentifiable,
    Destination: View
>: View {

    @Binding var path: [StackRoute]
    let destination: (StackRoute) -> Destination

    var body: some View {
        NavigationLink(
            destination: LegacyLevel(path: $path, destination: destination),
            isActive: isActiveBinding
        ) { EmptyView() }
        .hidden()
    }

    private var isActiveBinding: Binding<Bool> {
        Binding(
            get: { !path.isEmpty },
            set: { isActive in
                if !isActive {
                    _ = path.popLast()
                }
            }
        )
    }
}

private struct LegacyLevel<
    StackRoute: RouteIdentifiable,
    Destination: View
>: View {

    @Binding var path: [StackRoute]
    let destination: (StackRoute) -> Destination

    var body: some View {
        if let route = path.last {
            ZStack {
                destination(route)
                LegacyPushLink(path: $path, destination: destination)
            }
        } else {
            EmptyView()
        }
    }
}
