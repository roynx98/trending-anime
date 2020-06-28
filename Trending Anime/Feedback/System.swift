//
//  System.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 14/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import Combine

struct FSM {
    
    /// Change the state based on the reduce function and applies side effects
    /// trough feedbacks.
    static func system<State, Event, Scheduler: Combine.Scheduler>(
        initial: State,
        reduce: @escaping (State, Event) -> State,
        // Context about where and when a publicher exectues
        scheduler: Scheduler,
        feedbacks: [Feedback<State, Event>]
    ) -> AnyPublisher<State, Never> {
        // We generate a publisher for our current state
        let state = CurrentValueSubject<State, Never>(initial)
        let events = feedbacks.map { feedback in feedback.run(state.eraseToAnyPublisher()) }
        
        return Deferred {
            // [1, 2, 3] [4, 5, 6] => [1, 2, 3, 4, 5, 6]
            Publishers.MergeMany(events)
                // Changes a scheduler for all publishers that come after it.
                .receive(on: scheduler)
                // From events to states
                .scan(initial, reduce)
                .handleEvents(receiveOutput: state.send)
                .prepend(initial)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
