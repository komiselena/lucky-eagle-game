//
//  GameContainerView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @State private var eagleScene = EagleGameScene(size: CGSize(width: 390, height: 844))
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var gameData: GameData

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        if gameViewModel.isGameOver {
            WinView(gameViewModel: gameViewModel, gameData: gameData)
                .navigationBarBackButtonHidden()
            } else {
                GeometryReader { g in
                    ZStack {
                        
                        SpriteView(scene: eagleScene)
                            .ignoresSafeArea()
                            .environmentObject(gameViewModel)
                        
                        VStack{
                            VStack {
                                HStack {
                                    Button(action: {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }) {
                                        Image("crossButton")
                                            .resizable()
                                            .frame(width: g.size.width * 0.08, height: g.size.width * 0.08)
                                            .padding(.leading, 10)
                                            .padding(.top, 10)
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    eagleScene.moveEagle(left: true)
                                }) {
                                    Image("leftArrow")
                                        .resizable()
                                        .frame(width: g.size.width * 0.1, height: g.size.width * 0.1)
                                        .padding()
                                }
                                
                                Spacer()
                                Button(action: {
                                    eagleScene.moveEagle(left: false)
                                }) {
                                    Image("rightArrow")
                                        .resizable()
                                        .frame(width: g.size.width * 0.1, height: g.size.width * 0.1)
                                        .padding()
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                            .navigationBarBackButtonHidden()
                            .onAppear {
                                eagleScene.score = 0
                                eagleScene.scaleMode = .resizeFill
                                eagleScene.gameViewModel = gameViewModel
                                eagleScene.gameData = gameData
                                
                            }
                        }
                    }
                }
        }
    }
}

class GameViewModel: ObservableObject {
    
    @Published var isGameOver = false
    var backgroundImage: String = "loc1"
    var eagleSkin: String = "eagle1"
    

}
