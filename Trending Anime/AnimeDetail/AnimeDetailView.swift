//
//  AnimeDetailView.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 21/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import SwiftUI

struct AnimeDetailView: View {
    var animeItem: AnimeItem
    
    var body: some View {
        VStack {
            Text(animeItem.title)
        }
    }
}

struct AnimeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AnimeDetailView(animeItem: AnimeItem(title: "", type: "", imageUrl: "", episodes: 1))
    }
}
