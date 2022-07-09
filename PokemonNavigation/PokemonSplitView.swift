//
//  PokemonSplitView.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/9/22.
//

import SwiftUI

struct PokemonSplitView: View {
    @StateObject private var viewModel = SplitViewModel()
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var pokemonService: PokemonService
    @SceneStorage("navigationURL") var navigationURL: URL?
    @State private var sidebarVisibility = NavigationSplitViewVisibility.all
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {
            List(viewModel.types, selection: $navigationState.selectedType) { type in
                NavigationLink(type.title, value: type)
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        UIPasteboard.general.string = try? navigationState.url?.absoluteString ?? ""
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Pokemon Type")
        } content: {
            PokemonTypeView(
                pokemon: viewModel.pokemon,
                columns: 1,
                selectedPokemon: $navigationState.selectedPokemon
            )
            .navigationTitle(navigationState.selectedType?.title ?? "None")
        } detail: {
            NavigationStack(path: $navigationState.path) {
                if let pokemon = navigationState.selectedPokemon {
                    PokemonView(pokemon: pokemon).id(pokemon)
                } else {
                    Text("Select a pokemon").navigationTitle("Pokemon")
                }
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                PokemonView(pokemon: pokemon).id(pokemon)
            }
        }
        .task { await viewModel(navigationURL: navigationURL, navigationState: navigationState, pokemonService: pokemonService) }
        .onChange(of: scenePhase) { phase in
            guard phase == .inactive else { return }
            navigationURL = try? navigationState.url
        }
    }
}
