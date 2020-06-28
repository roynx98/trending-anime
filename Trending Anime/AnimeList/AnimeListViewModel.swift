//
//  AnimeListViewModel.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 13/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import Foundation
import Combine

final class AnimeListViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init() {
        FSM.system(
            initial: state,
            // It's the same as AnimeList.reduce
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                // Functions that receive an state and return an event
                Self.userInput(input: input.eraseToAnyPublisher()),
                Self.whenLoading()
            ])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }

    deinit {
        bag.removeAll()
    }
    
    func send(event: Event) {
        input.send(event)
    }
    
}

extension AnimeListViewModel {
    enum State: CustomStringConvertible {
        case idle
        case loading
        case loaded(LoadedPayload)
        case error(Error)
        
        var description: String {
            switch self {
            case .idle: return "idle"
            case .loading: return "loading"
            case .loaded: return "loaded"
            case .error: return "error"
            }
        }
        
        var value: Any? {
            switch self {
            case .idle: return nil
            case .loading: return nil
            case .loaded(let data): return data
            case .error(let data): return data
            }
        }
    }
    
    struct LoadedPayload {
        let list: [AnimeItem]
        var currentAnime: AnimeItem?
    }

    enum Event {
        case onAppear
        case onReload
        case onSelectAnime(AnimeItem)
        case onAnimesLoaded([AnimeItem])
        case onFailedToLoadAnimes(Error)
    }
}

// MARK: - State Machine
extension AnimeListViewModel {
    
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFailedToLoadAnimes(let error):
                return .error(error)
            case .onAnimesLoaded(let animes):
                return .loaded(LoadedPayload(list: animes))
            default:
                return state
            }
        case .loaded(var payload):
            switch event {
            case .onSelectAnime(let anime):
                payload.currentAnime = anime
                return .loaded(payload)
            default:
                return state
            }
        case .error:
            switch event {
            case .onReload:
                return .loading
            default:
                return state
            }
        }
      
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
    
    static func whenLoading() -> Feedback<State, Event> {
        return Feedback { (state: State) -> AnyPublisher<Event, Never> in
            
            guard case .loading = state else {
                return Empty().eraseToAnyPublisher()
            }
            
            return AnimeAPI().getTops()
                // onAnimesLoaded behaves as a function
                .map(Event.onAnimesLoaded)
                .catch { Just(Event.onFailedToLoadAnimes($0)) }
                .eraseToAnyPublisher()
        }
    }
    
}
