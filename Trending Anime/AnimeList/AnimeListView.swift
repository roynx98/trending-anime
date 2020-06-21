//
//  AnimeListView.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 13/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct AnimeListView: View {
    @ObservedObject var viewModel = AnimeListViewModel()
    
    var body: some View {
        ZStack {
            Color("background1")
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.state == .loading {
                LoadingContentView()
            } else if viewModel.state == .idle {
                Text("Idle").onAppear { self.viewModel.send(event: .onAppear) }

                //TODO: Improve it
            } else if viewModel.state == .loaded([]) {
                LoadedContentView(state: viewModel.state)
            } else {
                Text("Default")
            }
        }
    }
}

struct AnimeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnimeListView()
    }
}

// MARK: Content States
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

struct IdleContentView: View {
    var body: some View {
        VStack {
            Text("Idle")
        }
    }
}

struct LoadedContentView: View {
    @State var list: [AnimeItem] = []
    var state: AnimeListViewModel.State
    
    init(state: AnimeListViewModel.State) {
        self.state = state
    }
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 22) {
                Text("Trending")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 22)
                    .padding(.top, 30)
                ForEach(list.indices, id: \.self) { item in
                    HStack(spacing: 22) {
                        WebImage(url:  URL(string: self.list[item].imageUrl))
                            .resizable()
                            .placeholder {
                                Rectangle().foregroundColor(.gray)
                            }
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 154)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(radius: 10, x: 0, y: 10)
                            .padding(.leading, 22)
                        VStack(alignment: .leading) {
                            Text(self.list[item].type)
                                .font(.footnote)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 10)
                                .foregroundColor(Color.white)
                                .background(Color(.red))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            Text(self.list[item].title)
                                .font(.headline)
                                .padding(.top, 15)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }.onAppear {
            if case let AnimeListViewModel.State.loaded(list) = self.state {
                self.list = list
                print(list)
            }
        }
    }
}
