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
    enum State : Equatable {
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
    }

    enum Event {
        case onAppear
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
            return state
        case .error:
            return state
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
                // TODO: Why does it work?
                .map(Event.onAnimesLoaded)
                .catch { Just(Event.onFailedToLoadAnimes($0)) }
                .eraseToAnyPublisher()
        }
    }
    
}
