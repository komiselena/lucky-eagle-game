//
//  MainMenuView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject var gameData: GameData = GameData()
    @ObservedObject var gameViewModel = GameViewModel()
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                GeometryReader { g in
                    ZStack {
                        Image("bg_main")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                        VStack{
                            HStack(alignment: .top){
                                NavigationLink(destination: MiniGamesView(gameData: gameData)) {
                                    Image("btn_minigames")
                                        .resizable()
                                        .frame(width: g.size.width * 0.08, height: g.size.width * 0.08)
                                    
                                }
                                .padding()
                                
                                Spacer()
                                
                                VStack(spacing: 5){
                                    Image("score")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.1, height: g.size.height * 0.05)
                                    ZStack{
                                        Image("Group 8")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.15, height: g.size.height * 0.09)
                                        HStack{
                                            Image("coin")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.05)
                                            Text("\(gameData.coins)")
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 10)
                                        }
                                        .frame(width: g.size.width * 0.15, height: g.size.height * 0.09)
                                    }
                                    Image("Group 308")
                                        .resizable()
                                        .scaledToFit()
                                    //                                    .frame(width: g.size.width * 0.2, height: g.size.width * 0.2)
                                    
                                }
                                .padding(.top, g.size.height * 0.05)
                                
                                Spacer()
                                NavigationLink(destination: SettingsView()) {
                                    Image("btn_settings")
                                        .resizable()
                                        .frame(width: g.size.width * 0.08, height: g.size.width * 0.08)
                                    
                                }
                                .padding()
                            }
                            .padding(.top, g.size.height * 0.15)
                            .frame(width: g.size.width * 0.8)

                            Spacer()
                            
                            
                            VStack(spacing: 20) {
                                NavigationLink(destination: GameContainerView(gameViewModel: gameViewModel, gameData: gameData)) {
                                    Image("Group 11-3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.34)
                                    
                                }
                                
                                HStack(spacing: 200){
                                    NavigationLink(destination: ShopView(gameViewModel: gameViewModel, gameData: gameData)) {
                                        Image("Group 12-4")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.17)
                                        
                                    }
                                    
                                    NavigationLink(destination: AchievementsView()) {
                                        Image("achieve")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.2)
                                        
                                    }
                                    
                                }
                            }
                            .padding(.bottom, g.size.height * 0.17)
                        }
                    }
                    .frame(width: g.size.width, height: g.size.height)
                }
            }

            } else {
                NavigationView {
                    GeometryReader { g in
                        ZStack {
                            Image("bg_main")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                            VStack{
                                HStack(alignment: .top){
                                    NavigationLink(destination: MiniGamesView(gameData: gameData)) {
                                        Image("btn_minigames")
                                            .resizable()
                                            .frame(width: g.size.width * 0.08, height: g.size.width * 0.08)
                                        
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 5){
                                        Image("score")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.1, height: g.size.height * 0.05)
                                        ZStack{
                                            Image("Group 8")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.15, height: g.size.height * 0.09)
                                            HStack{
                                                Image("coin")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.05)
                                                Text("\(gameData.coins)")
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 10)
                                            }
                                            .frame(width: g.size.width * 0.15, height: g.size.height * 0.09)
                                        }
                                        Image("Group 308")
                                            .resizable()
                                            .scaledToFit()
                                        //                                    .frame(width: g.size.width * 0.2, height: g.size.width * 0.2)
                                        
                                    }
                                    .padding(.top, g.size.height * 0.05)
                                    
                                    Spacer()
                                    NavigationLink(destination: SettingsView()) {
                                        Image("btn_settings")
                                            .resizable()
                                            .frame(width: g.size.width * 0.08, height: g.size.width * 0.08)
                                        
                                    }
                                    .padding()
                                }
                                .padding(.top, g.size.height * 0.15)
                                Spacer()
                                
                                
                                VStack(spacing: 20) {
                                    NavigationLink(destination: GameContainerView(gameViewModel: gameViewModel, gameData: gameData)) {
                                        Image("Group 11-3")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.34)
                                        
                                    }
                                    
                                    HStack(spacing: 200){
                                        NavigationLink(destination: ShopView(gameViewModel: gameViewModel, gameData: gameData)) {
                                            Image("Group 12-4")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.17)
                                            
                                        }
                                        
                                        NavigationLink(destination: AchievementsView()) {
                                            Image("achieve")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.2)
                                            
                                        }
                                        
                                    }
                                }
                                .padding(.bottom, g.size.height * 0.17)
                            }
                        }
                        .frame(width: g.size.width, height: g.size.height)
                    }
                }
            }
        }
}


#Preview {
    MainMenuView()
}
