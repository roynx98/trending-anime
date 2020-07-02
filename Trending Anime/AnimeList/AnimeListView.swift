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
                LoadedContentView(viewModel: viewModel)
            } else if viewModel.state.description == "error" {
                ErrorContentView(viewModel: viewModel, error: viewModel.state.value as! Error)
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
        }
    }
    
}

struct IdleContentView: View {
    var body: some View {
        Text("")
    }
}

struct LoadedContentView: View {
    let typeColorMapping = ["TV": Color.red, "Movie": Color.purple, "OVA": Color.green]
    @ObservedObject var viewModel: AnimeListViewModel
    @State var showDetails = false
    
    func getVal() -> AnimeListViewModel.LoadedPayload {
        return viewModel.state.value as! AnimeListViewModel.LoadedPayload
    }
    
    func calculateScale(x: CGFloat) -> CGFloat {
        let dist = abs(screen.width / 2 - x) / (screen.width / 2)
        return 0.9 + (0.2 * (1 - dist))
    }
    
    var body: some View {
        
        ZStack {
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 20) {
                    HStack {
                        Text("🔭 Discover")
                            .bold()
                    }.padding(.top, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<10, id: \.self) { index in
                                // TODO: Add zoom animation
                                GeometryReader { proxy in
                                    WebImage(url:  URL(string: self.getVal().list[index].imageUrl))
                                        .resizable()
                                        .placeholder { Rectangle().foregroundColor(.gray) }
                                        .renderingMode(.original)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .frame(width: 180, height: 277)
                                        .aspectRatio(contentMode: .fill)
                                        .shadow(radius: 10, x: 0, y: 10)
                                        .padding(.leading, 15)
                                        .onTapGesture {
                                            self.showDetails = true
                                            self.viewModel.send(event: .onSelectAnime(self.getVal().list[index]))
                                        }
                                    .scaleEffect(self.calculateScale(x: proxy.frame(in: .global).minX + 90))
                                }.frame(width: 180, height: 277)
                            }
                        }
                        .padding(30)
                        .padding(.bottom, 10)
                    }
                    
                    Text("⭐️ Trending")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    ForEach(10..<getVal().list.count, id: \.self) { index in
                        HStack(spacing: 10) {
                            WebImage(url:  URL(string: self.getVal().list[index].imageUrl))
                                .resizable()
                                .placeholder { Rectangle().foregroundColor(.gray) }
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .frame(width: 120, height: 154)
                                .aspectRatio(contentMode: .fit)
                                .shadow(radius: 10, x: 0, y: 10)
                                .padding(.leading, 15)
                            VStack(alignment: .leading) {
                                Text(self.getVal().list[index].type)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 10)
                                    .foregroundColor(Color.white)
                                    .background(self.typeColorMapping[self.getVal().list[index].type, default: Color.black])
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                Text(self.getVal().list[index].title)
                                    .font(.system(size: 22))
                                    .padding(.top, 15)
                                Text("Episodes \(self.getVal().list[index].episodes)")
                                    .font(.footnote)
                                    .foregroundColor(Color.gray)
                                    .padding(.top, 15)
                                
                                Spacer()
                            }
                            Spacer()
                        }.background(Color("background1"))
                        .onTapGesture {
                            self.showDetails = true
                            self.viewModel.send(event: .onSelectAnime(self.getVal().list[index]))
                        }
                    }
                }
            }
            
            if (self.showDetails) {
                AnimeDetailView(viewModel: AnimeDetailViewModel(animeID: self.getVal().currentAnime!.malId), currentAnime: self.getVal().currentAnime!, dissmiss: $showDetails)
                    .transition(.move(edge: .trailing))
                    .animation(Animation.default.speed(1.5))
                    .zIndex(1)
                    // It will rebuild the view, for fixing the text animations problems
                    .id(UUID())
            }
        }
    }
}

struct ErrorContentView: View {
    var viewModel: AnimeListViewModel
    var error: Error
    
    var body: some View {
        VStack {
            Image("error")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180)
            Text(error.localizedDescription)
            Button(action: { self.viewModel.send(event: .onReload) }) {
                Text("Try again")
            }.padding(.top)
        }
    }
}

let screen = UIScreen.main.bounds
