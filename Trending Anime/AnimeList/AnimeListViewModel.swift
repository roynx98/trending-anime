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
        Test.system(
            initial: state,
            // It's the same as AnimeList.reduce
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
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
    enum State: Equatable, CustomStringConvertible {
        static func == (lhs: AnimeListViewModel.State, rhs: AnimeListViewModel.State) -> Bool {
            
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.loaded, .loaded):
                return true
            default:
                return false
            }
        }
        
        case idle
        case loading
        case loaded([AnimeItem])
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
                return .loaded(animes)
            default:
                return state
            }
        case .loaded:
            switch event {
            case .onSelectAnime(let anime):
                return state
            default:
                return state
            }
            return state
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
