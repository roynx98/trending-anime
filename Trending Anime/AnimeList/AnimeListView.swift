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
    
    var body: some View {
        ZStack {
            Color("background2")
                .edgesIgnoringSafeArea(.all)
            
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
        AnimeListView().environment(\.colorScheme, .dark)
    }
}

struct LoadingContentView: View {
    @State var isAnimating = false
    
    var body: some View {
        VStack {
            Image("kunai")
                .resizable()
                .frame(width: 64, height: 64)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1.5)
                           .repeatForever(autoreverses: false))
                .onAppear {
                    self.isAnimating = true
            }
            Text("Loading...").padding(.top, 10)
        }
    }
}
