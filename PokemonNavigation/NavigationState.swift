//
//  NavigationState.swift
//  PokemonNavigation
//
//  Created by Joshua Homann on 7/9/22.
//

import SwiftUI

@MainActor
final class NavigationState: ObservableObject {
    @Published var selectedType: SplitViewModel.PokemonType?
    @Published var selectedPokemon: Pokemon?
    @Published var path = NavigationPath()
    var url: URL? {
        get throws {
            var components = URLComponents()
            components.scheme = "pokemon"
            components.host = "pokemon"
            components.path = ["/"] + ([selectedType?.id, selectedPokemon?.name]
                .compactMap {$0}
                .joined(separator: "/"))
            let strings = try path.codable.map { try JSONEncoder().encode($0) }
                .flatMap { try JSONDecoder().decode([String].self, from: $0) } ?? []
            let pairs = zip(
                strings.indices.reversed().filter { $0.isMultiple(of: 2) },
                strings.indices.reversed().filter { !$0.isMultiple(of: 2) }
            )
                .lazy
                .compactMap { keyIndex, valueIndex in
                    strings[valueIndex].data(using: .utf8).map { data in (strings[keyIndex], data) }
                }
            components.queryItems = try pairs.compactMap { key, data in
                switch key {
                case String(reflecting: String.self):
                    return .init(name: "type", value: try JSONDecoder().decode(String.self, from: data))
                case String(reflecting: Pokemon.self):
                    return .init(name: "pokemon", value: try JSONDecoder().decode(Pokemon.self, from: data).name)
                default: return nil
                }
            }
            return components.url
        }
    }

    func navigate(to url: URL, pokemonService: PokemonService) async {
        let components = url.pathComponents.dropFirst()
        if let type = components.first {
            selectedType = .init(id: type, title: type.capitalized)
        }
        if let name = components.dropFirst().first {
            selectedPokemon = await pokemonService.pokemon(name: name)
        }
        path.removeLast(path.count)
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return }
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            switch queryItem.name {
            case "type":
                path.append(value)
            case "pokemon":
                guard let pokemon = await pokemonService.pokemon(name: value) else { continue }
                path.append(pokemon)
            default: continue
            }
        }

    }
}
