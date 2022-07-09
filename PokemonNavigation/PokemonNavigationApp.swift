//
//  PokemonNavigationApp.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/2/22.
//

import SwiftUI

@main
struct PokemonNavigationApp: App {
    @StateObject private var pokemonService = PokemonService()
    var body: some Scene {
        PokemonScene(pokemonService: pokemonService)
    }
}

struct PokemonScene: Scene {
    @StateObject private var navigationState = NavigationState()
    var pokemonService: PokemonService
    var body: some Scene {
        WindowGroup {
            PokemonSplitView()
                .environmentObject(pokemonService)
                .environmentObject(navigationState)
                .onOpenURL { url in
                    Task { await navigationState.navigate(to: url, pokemonService: pokemonService) }
                }
        }
    }
}
