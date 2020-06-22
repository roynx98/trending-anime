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
                .onAppear { self.viewModel.send(event: .onAppear) }
            
            if viewModel.state.description == "loading" {
                LoadingContentView()
            } else if viewModel.state.description == "idle" {
                IdleContentView()
            } else if viewModel.state.description == "loaded" {
                LoadedContentView(list: viewModel.state.value as! [AnimeItem])
            } else if viewModel.state.description == "error" {
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
        Group {
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
            }
        }
    }
}

struct IdleContentView: View {
    var body: some View {
        Group {
            Text("Idle")
        }
    }
}

struct LoadedContentView: View {
    @State var list: [AnimeItem] = []
    var typeColorMapping = ["TV": Color.red, "Movie": Color.purple, "OVA": Color.green]
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 20) {
                    HStack {
                        Text("🔭 Discover")
                            .bold()
                    }.padding(.top, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<10, id: \.self) { index in
                                // TODO: Add zoom animation
                                NavigationLink(destination:
                                    AnimeDetailView()
                                        .navigationBarTitle("")
                                        .navigationBarHidden(true)
                                .navigationBarHidden(true)) {
                                    GeometryReader { proxy in
                                        WebImage(url:  URL(string: self.list[index].imageUrl))
                                            .resizable()
                                            .placeholder {
                                                Rectangle().foregroundColor(.gray)
                                        }
                                        .renderingMode(.original)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 180, height: 277)
                                        .shadow(radius: 10, x: 0, y: 10)
                                        .padding(.leading, 15)
                                    }.frame(width: 180, height: 277)
                                }
                            }
                        }.padding(.vertical, 30)
                    }
                    
                    Text("⭐️ Trending")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    ForEach(10..<list.count, id: \.self) { index in
                        HStack(spacing: 10) {
                            WebImage(url:  URL(string: self.list[index].imageUrl))
                                .resizable()
                                .placeholder {
                                    Rectangle().foregroundColor(.gray)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 154)
                            .shadow(radius: 10, x: 0, y: 10)
                            .padding(.leading, 15)
                            VStack(alignment: .leading) {
                                Text(self.list[index].type)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 10)
                                    .foregroundColor(Color.white)
                                    .background(self.typeColorMapping[self.list[index].type, default: Color.black])
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                Text(self.list[index].title)
                                    .font(.system(size: 22))
                                    .padding(.top, 15)
                                Text("Episosdes \(self.list[index].episodes)")
                                    .font(.footnote)
                                    .foregroundColor(Color.gray)
                                    .padding(.top, 15)
                                
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }.navigationBarTitle("")
                .navigationBarHidden(true)
                
            }
        }
    }
}
