//
//  GameContainerView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @State private var eagleScene = EagleGameScene(size: UIScreen.main.bounds.size)
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
                    
                    VStack {
                        // Кнопка выхода
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
                        
                        // Панель управления
                        HStack {
                            // Левая кнопка
                            Button(action: {}) {
                                Image("leftArrow")
                                    .resizable()
                                    .frame(width: g.size.width * 0.12, height: g.size.width * 0.12)
                                    .padding()
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        eagleScene.rotateEagle(clockwise: false, start: true)
                                    }
                                    .onEnded { _ in
                                        eagleScene.rotateEagle(clockwise: false, start: false)
                                    }
                            )
                            
                            Spacer()
                            
                            // Правая кнопка
                            Button(action: {}) {
                                Image("rightArrow")
                                    .resizable()
                                    .frame(width: g.size.width * 0.12, height: g.size.width * 0.12)
                                    .padding()
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        eagleScene.rotateEagle(clockwise: true, start: true)
                                    }
                                    .onEnded { _ in
                                        eagleScene.rotateEagle(clockwise: true, start: false)
                                    }
                            )
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .onAppear {
                let newScene = EagleGameScene(size: UIScreen.main.bounds.size)
                newScene.scaleMode = .resizeFill
                newScene.gameViewModel = gameViewModel
                newScene.gameData = gameData
                eagleScene = newScene
            }
            .navigationBarBackButtonHidden()
        }
    }
}

class GameViewModel: ObservableObject {
    @Published var isGameOver = false
    var backgroundImage: String = "loc1"
    var eagleSkin: String = "eagle1"
}
