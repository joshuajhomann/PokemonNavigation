//
//  ContentView.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/2/22.
//

import SwiftUI

@MainActor
final class SplitViewModel: ObservableObject {

    @Published private(set) var types: [PokemonType] = []
    @Published var pokemon: [Pokemon] = []

    struct PokemonType: Identifiable, Hashable {
        var id: String
        var title: String
    }

    func callAsFunction(navigationURL: URL?, navigationState: NavigationState, pokemonService: PokemonService) async {
        if let navigationURL {
            await navigationState.navigate(to: navigationURL, pokemonService: pokemonService)
        }

        types = pokemonService.types.map { .init(id: $0, title: $0.capitalized) }

        Task {
            for await selection in navigationState.$selectedType.values.dropFirst() {
                if let selection {
                    pokemon = await pokemonService.pokemonOf(type: selection.id)
                } else {
                    pokemon = []
                }
                navigationState.path.removeLast(navigationState.path.count)
            }
        }

        Task {
            for await _ in navigationState.$selectedPokemon.values.dropFirst() {
                navigationState.path.removeLast(navigationState.path.count)
            }
        }
    }
}
