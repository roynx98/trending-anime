//
//  AnimeDetailView.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 21/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUI

struct AnimeDetailView: View {
    @ObservedObject var viewModel: AnimeDetailViewModel
    var currentAnime: AnimeItem
    @Binding var dissmiss: Bool
    @State var rating: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color("background1")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack() {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .padding()
                            .padding(.leading, 10)
                            .onTapGesture {
                                self.dissmiss = false
                        }
                        Spacer()
                    }.padding(.top, 10)

                    Text(currentAnime.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    HStack() {
                        BubbleText(text: "Released \(currentAnime.startDate)", color: Color.blue)
                        if viewModel.state.description == "loaded" {
                             BubbleText(text: (viewModel.state.value as! AnimeDetail).status, color: Color.green)
                        } else {
                            BubbleText(text: "", color: Color.green)
                        }
                        Spacer()
                    }.padding(.leading, 18)
                    
                    VStack(alignment: .center) {
                        WebImage(url: URL(string: currentAnime.imageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: screen.width - 40, height: screen.width / 4 * 3)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                    }.frame(width: screen.width)
                    
                    HStack {
                        if viewModel.state.description == "loaded" {
                            Text((viewModel.state.value as! AnimeDetail).rating)
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                        if viewModel.state.description == "loaded" {
                            Text((viewModel.state.value as! AnimeDetail).duration)
                                .foregroundColor(Color.gray)
                        } else {
                            // To left a space
                            Text(" ")
                        }
                    }.padding(.horizontal, 20)
                    
                    RatingView(per: $rating)
                        .padding(.leading, 20)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.rating = CGFloat(self.currentAnime.score / 10.0)
                            }
                        }
                    
                    if viewModel.state.description == "loaded" {
                        Text((viewModel.state.value as! AnimeDetail).synopsis)
                            .frame(height: 150)
                            .padding(.horizontal, 20)
                    } else {
                        // TODO Put an effect
                        Text("...")
                            .frame(height: 150)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
        }.onAppear {
            self.viewModel.send(event: .onAppear)
        }
    }
}

struct BubbleText: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.bold)
            .padding(.vertical, 2)
            .padding(.horizontal, 10)
            .foregroundColor(Color.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

//struct AnimeDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimeDetailView(currentAnime: AnimeItem(title: "One Punch Man", type: "", imageUrl: "", episodes: 2, startDate: "ss", score: 0), dissmiss: .constant(true))
//    }
//}

struct RatingView: View {
    @Binding var per: CGFloat
    let barWidth: CGFloat = 120
    
    var body: some View {
        ZStack {
            
            HStack() {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: self.barWidth, height: 20)
                    .mask(HStack(spacing: 5) {
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                    })
                Spacer()
            }.frame(width: barWidth + 10, height: 20)
          
            HStack() {
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: barWidth - barWidth * (1 - per), height: 20)
                    .mask(HStack(spacing: 5) {
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                        Image("shuriken").resizable().frame(width: 20, height: 20)
                    })
                Spacer()
            }.frame(width: barWidth + 10, height: 20)
        }
    }
}
