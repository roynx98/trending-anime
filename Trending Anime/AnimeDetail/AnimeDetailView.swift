//
//  AnimeDetailView.swift
//  Trending Anime
//
//  Created by Roy Rodriguez on 21/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct AnimeDetailView: View {
    var currentAnime: AnimeItem
    @Binding var dissmiss: Bool
    
    var body: some View {
        ZStack {
            Color("background1")
            
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .padding()
                        .padding(.leading, 10)
                        .onTapGesture {
                            self.dissmiss = false
                    }
                    Spacer()
                }.padding(.top, 50)
                
                Text(currentAnime.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                HStack() {
                    BubbleText(text: "Released Jan 7, 2019", color: Color.yellow)
                    BubbleText(text: "Finished", color: Color.green)
                    Spacer()
                }.padding(.leading, 18)
                
                Image("one")
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.horizontal)
                    .frame(width: screen.width, height: screen.width / 4 * 3)
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 10, x: 0, y: 10)
                
                Spacer()
            }
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
