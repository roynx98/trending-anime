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
                Self.userInput(input: input.eraseToAnyPublisher())
            ])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }

    deinit {
        bag.removeAll()
    }
    
    // 3.
    func send(event: Event) {
        input.send(event)
    }
    
    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            return Empty().eraseToAnyPublisher()
        }
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
            default:
                return false
            }
        }
        
        case idle
        case loading
        case loaded([ListItem])
        case error(Error)
    }

    enum Event {
        case onAppear
        case onSelectMovie(Int)
        case onMoviesLoaded([ListItem])
        case onFailedToLoadMovies(Error)
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
            case .onFailedToLoadMovies(let error):
                return .error(error)
            case .onMoviesLoaded(let movies):
                return .loaded(movies)
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
    
}

struct ListItem {
    var name = ""
}
