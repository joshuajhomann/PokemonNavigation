//
//  PokemonService.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/2/22.
//

import Foundation

actor PokemonService: ObservableObject {
    let types: [String]
    private let typeToPokemonIds: [String: [String]]
    private let nameToPokemon: [String: Pokemon]
    private let idToPokemon: [String: Pokemon]
    init() {
        let pokemon = Pokemon.all
        idToPokemon = .init(uniqueKeysWithValues: zip(pokemon.lazy.map(\.id), pokemon))
        nameToPokemon = .init(uniqueKeysWithValues: zip(pokemon.lazy.map(\.name), pokemon))
        typeToPokemonIds = pokemon.reduce(into: [String: [String]]()) { lookup, pokemon in
            pokemon.types.forEach { type in
                lookup[type] = lookup[type, default: []] + [pokemon.id]
            }
        }
        types = typeToPokemonIds.keys.sorted()
    }

    func pokemon(id: String) -> Pokemon? {
        idToPokemon[id]
    }

    func pokemon(name: String) -> Pokemon? {
        nameToPokemon[name]
    }

    func pokemonOf(type: String) -> [Pokemon] {
        typeToPokemonIds[type]?.compactMap { idToPokemon[$0] } ?? []
    }

}
