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
    @Published var selectedType: PokemonType?
    @Published var pokemon: [Pokemon] = []
    @Published var selectedPokemon: Pokemon?

    struct PokemonType: Identifiable, Hashable {
        var id: String
        var title: String
    }

    func callAsFunction(pokemonService: PokemonService) async {
        types = pokemonService.types.map { .init(id: $0, title: $0.capitalized) }
        
        for await selection in $selectedType.values {
            if let selection {
                pokemon = await pokemonService.pokemonOf(type: selection.id)
            } else {
                pokemon = []
            }
        }
    }
}

struct PokemonTypeView: View {
    var pokemon: [Pokemon]
    @Binding var selectedPokemon: Pokemon?
    var body: some View {
        List(pokemon, selection: $selectedPokemon) { pokemon in
            NavigationLink(pokemon.name, value: pokemon)
        }
    }
}

struct PokemonSplitView: View {
    @StateObject private var viewModel = SplitViewModel()
    @EnvironmentObject private var pokemonService: PokemonService
    @State private var sidebarVisiblity = NavigationSplitViewVisibility.all
    @State private var path: [Pokemon] = []
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisiblity) {
            List(viewModel.types, selection: $viewModel.selectedType) { type in
                NavigationLink(type.title, value: type)
            }
            .navigationTitle("Pokemon Type")
        } content: {
            PokemonTypeView(
                pokemon: viewModel.pokemon,
                selectedPokemon: $viewModel.selectedPokemon
            ).navigationTitle(viewModel.selectedType?.title ?? "None")
        } detail: {
            NavigationStack(path: $path) {
                if let pokemon = viewModel.selectedPokemon {
                    PokemonView(pokemon: pokemon)
                } else {
                    Text("Select a pokemon").navigationTitle("Pokemon")
                }
            }
        }
        .task { await viewModel(pokemonService: pokemonService) }
    }
}

struct PokemonView: View {
    var pokemon: Pokemon
    var body: some View {
        VStack {
            AsyncImage(url: pokemon.artURL)
            Text(pokemon.name).font(.largeTitle).fontWeight(.bold).padding()
            Text(pokemon.pokemonDescription)
            VStack {
                Text("EVOLUTIONS:").font(.subheadline).bold().underline()
                Text(pokemon.evolutions.map { $0.to }.joined(separator: ", "))
            }
            VStack {
                Text("TYPES:").font(.subheadline).bold().underline()
                Text(pokemon.types.map { $0.capitalized }.joined(separator: ", "))
            }
        }
        .padding()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonSplitView()
    }
}
