//
//  PokemonView.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/9/22.
//

import SwiftUI

struct PokemonView: View {
    @EnvironmentObject private var pokemonService: PokemonService
    @StateObject private var viewModel = PokemonViewModel()
    var pokemon: Pokemon
    var body: some View {
        VStack {
            AsyncImage(url: pokemon.artURL)
            Text(pokemon.name).font(.largeTitle).fontWeight(.bold).padding()
            Text(pokemon.pokemonDescription)
            VStack {
                Text("EVOLUTIONS:").font(.subheadline).bold().underline()
                if viewModel.evolutions.isEmpty {
                    Text("None")
                } else {
                    ForEach(viewModel.evolutions, id: \.id) { evolution in
                        NavigationLink(evolution.name, value: evolution)
                    }
                }
            }
            VStack {
                Text("TYPES:").font(.subheadline).bold().underline()
                Text(pokemon.types.map { $0.capitalized }.joined(separator: ", "))
            }
        }
        .padding()
        .navigationTitle(pokemon.name)
        .task { await viewModel(pokemon: pokemon, pokemonService: pokemonService) }
    }

}
