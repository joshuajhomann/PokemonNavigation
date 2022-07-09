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
        WindowGroup {
            PokemonSplitView()
                .environmentObject(pokemonService)
        }
    }
}
