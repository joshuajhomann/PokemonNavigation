//
//  PokemonTypeView.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/9/22.
//

import SwiftUI

struct PokemonTypeView: View {
    var pokemon: [Pokemon]
    var columns: Int
    @Binding var selectedPokemon: Pokemon?
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(), count: columns)) {
                ForEach(pokemon) { pokemon in
                    let isSelected = selectedPokemon?.id == pokemon.id
                    Button {
                        selectedPokemon = pokemon
                    } label: {
                        HStack(spacing: 20) {
                            AsyncImage(url: pokemon.artURL) { phase in
                                let background = RoundedRectangle(cornerSize:.init(width: 8,height: 8))
                                    .fill(Color(uiColor: .quaternarySystemFill))
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .background(background)
                                } else {
                                    background
                                }
                            }
                                .frame(width: 50, height: 50)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(pokemon.name)
                                Text(pokemon.pokemonDescription).lineLimit(1).foregroundColor(.secondary)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerSize:.init(width: 8,height: 8))
                                .fill(isSelected ? Color.accentColor : Color(uiColor: .tertiarySystemFill))
                        )
                        .frame(minHeight: 50)
                        .padding(.horizontal, 10)

                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
