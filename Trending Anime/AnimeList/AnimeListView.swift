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
            return Text("Idel")
        default:
            return Text("Defaulr")
        }
    }
    
    var body: some View {
        VStack {
            if viewModel.state == .loading {
                LoadingContentView()
            } else if viewModel.state == .idle {
                Text("Idle").onAppear { self.viewModel.send(event: .onAppear) }
            }
        }
    }
}

struct AnimeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnimeListView()
    }
}

struct LoadingContentView: View {
    @State var isAnimating = false
    
    var body: some View {
        Image("kunai")
            .resizable()
            .frame(width: 64, height: 64)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 2.0)
                       .repeatForever(autoreverses: false))
            .onAppear {
                self.isAnimating = true
        }
    }
}
