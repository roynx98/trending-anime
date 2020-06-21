//
//  Feedback.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 14/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import Foundation
import Combine

struct Feedback<State, Event> {
    let run: (AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>
}

extension Feedback {
    init<Effect: Publisher>(effects: @escaping (State) -> Effect) where Effect.Output == Event, Effect.Failure == Never {
        self.run = { state in
            state
                .map { effects($0) }
                // Only use the last request (For no ap)
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }
}
