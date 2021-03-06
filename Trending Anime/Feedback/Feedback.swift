//
//  Feedback.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 14/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import Foundation
import Combine

/// Functons that receive un state, then make solo logic and return an event
struct Feedback<State, Event> {
    let run: (AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>
}

extension Feedback {
    init<Effect: Publisher>(effects: @escaping (State) -> Effect) where Effect.Output == Event, Effect.Failure == Never {
        self.run = { state in
            return state
                // We execute our side effect and returns a new event
                .map { effects($0) }
                // Only use the last request
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }
}
