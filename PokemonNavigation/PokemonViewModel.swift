//
//  PokemonViewModel.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/9/22.
//

import SwiftUI

@MainActor
final class PokemonViewModel: ObservableObject {
    @Published private(set) var evolutions: [Pokemon] = []
    func callAsFunction(pokemon: Pokemon, pokemonService: PokemonService) async {
        var temp: [Pokemon] = []
        for name in pokemon.evolutions.lazy.map(\.to) {
            guard let pokemon = await pokemonService.pokemon(name: name) else { continue }
            temp.append(pokemon)
        }
        evolutions = temp
    }
}
