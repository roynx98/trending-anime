//
//  AnimeDetailViewModel.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 21/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import Foundation
import Combine

final class AnimeDetailViewModel: ObservableObject {
    @Published var state: State
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init(animeID: Int) {
        state = .idle(animeID)
        
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

extension AnimeDetailViewModel {
    enum State: CustomStringConvertible {
        case idle(Int)
        case loading(Int)
        case loaded(AnimeDetail)
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
        case onAnimeDetailLoaded(AnimeDetail)
        case onFailedToLoadAnimes(Error)
    }
}

// MARK: - State Machine
extension AnimeDetailViewModel {
    
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle(let animeID):
            switch event {
            case .onAppear:
                return .loading(animeID)
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFailedToLoadAnimes(let error):
                return .error(error)
            case .onAnimeDetailLoaded(let animeDetail):
                return .loaded(animeDetail)
            default:
                return state
            }
        case .loaded:
            return state
        case .error:
            switch event {
            case .onReload:
                return .loading(-1)
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
            guard case .loading(let id) = state else { return Empty().eraseToAnyPublisher() }
            
            return AnimeAPI().getDetail(animeID: id)
                // onAnimesLoaded behaves as a function
                .map(Event.onAnimeDetailLoaded)
                .catch { Just(Event.onFailedToLoadAnimes($0)) }
                .eraseToAnyPublisher()
        }
    }
    
}
