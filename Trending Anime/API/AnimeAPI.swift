//
//  AnimeAPI.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 21/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import Foundation
import Combine

struct AnimeAPI {
    
    func getTops() -> AnyPublisher<[AnimeItem], Error> {
        let url = URL(string: "https://api.jikan.moe/v3/top/anime")!
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return publisher.map(\.data)
            .decode(type: AnimeReponse.self, decoder: decoder)
            .map(\.top)
            .eraseToAnyPublisher()
    }
    
    func getDetail(animeID: Int) -> AnyPublisher<AnimeDetail, Error> {
        let url = URL(string: "https://api.jikan.moe/v3/anime/\(animeID)")!
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return publisher.map(\.data)
            .decode(type: AnimeDetail.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
}

struct AnimeDetail: Codable {
    var synopsis: String
}

struct AnimeReponse: Codable {
    var top: [AnimeItem]
}

struct AnimeItem: Codable {
    var title: String
    var malId: Int
    var type: String
    var imageUrl: String
    var episodes: Int
    var startDate: String
    var score: Float
}
