//
//  AnimeListView.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 13/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import SwiftUI

struct AnimeListView: View {
    @ObservedObject var viewModel = AnimeListViewModel()
    
    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Text("Idel")
        case .loading:
            return Text("Loading")
        default:
            return Text("Defaulr")
        }
    }
    
    var body: some View {
        VStack {
            content
            Button(action: { self.viewModel.send(event: .onAppear) }) {
                Text("Popo")
            }
        }
    }
}

struct AnimeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnimeListView()
    }
}
