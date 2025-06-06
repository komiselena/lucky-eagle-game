//
//  ShopView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct ShopView: View {
    
    enum Tab {
        case skins
        case locations
    }

    @State private var selectedTab: Tab = .skins
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var gameViewModel: GameViewModel

    @ObservedObject var gameData: GameData
    
    var body: some View {
        GeometryReader { g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Button(action: {
                            selectedTab = .skins
                        }) {
                            Image(selectedTab == .skins ? "Skins" : "Skins2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.18)
                        }
                        
                        Button(action: {
                            selectedTab = .locations
                        }) {
                            Image(selectedTab == .locations ? "Locations" : "Locations2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.18)
                        }
                        
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("crossButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.1)

                        }
                        
                    }
                    .frame(width: g.size.width * 0.8)
                    
                    
                    
                    if selectedTab == .skins {
                        
                        Image("eagleSkin")
                            .resizable()
                            .scaledToFit()
                            .overlay (
                                HStack(spacing: g.size.width * 0.07){
                                    ForEach(1..<5, id: \.self){ id in
                                        Button {
                                            handleSkinButton(id: id)
                                        } label: {
                                            Image(currentSkinButtonImage(for: id))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.12)
                                        }

                                    }
                                }
                                    .padding(.bottom)
                                ,alignment: .bottom
                            )
                            .frame(width: g.size.width * 0.8, height: g.size.height * 0.88)

                    } else {
                        Image("desertLocation")
                            .resizable()
                            .scaledToFit()
                            .overlay (
                                HStack(spacing: g.size.width * 0.07){
                                    ForEach(1..<5, id: \.self){ id in
                                        Button {
                                            handleLocationButton(id: id)
                                        } label: {
                                            Image(currentLocButtonImage(for: id))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.12)
                                        }

                                    }
                                }
                                    .padding(.bottom)
                                ,alignment: .bottom
                            )
                            .frame(width: g.size.width * 0.8, height: g.size.height * 0.8)


                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationBarBackButtonHidden()
        }
    }
    private func handleSkinButton(id: Int) {
        if gameData.boughtSkinId.contains(id) {
            gameViewModel.eagleSkin = "eagle\(id)"
        } else {
            if gameData.coins >= 100 {
                gameData.coins -= 100
                gameData.boughtSkinId.append(id)
                gameViewModel.eagleSkin = "eagle\(id)"
            } else {
                print("Not enough money")
            }
        }
    }
    
    private func handleLocationButton(id: Int) {
        if gameData.boughtLocId.contains(id) {
            gameViewModel.backgroundImage = "loc\(id)"
        } else {
            if gameData.coins >= 100 {
                gameData.coins -= 100

                gameData.boughtLocId.append(id)
                gameViewModel.backgroundImage = "loc\(id)"
            } else {
                print("Not enough money")

            }
        }
    }
    
    private func currentSkinButtonImage(for id: Int) -> String {
        if gameData.boughtSkinId.contains(id) {
            return "Use"
        } else {
            return "100Coins"
        }
    }

    private func currentLocButtonImage(for id: Int) -> String {
        if gameData.boughtLocId.contains(id) {
            return "Use"
        } else {
            return "100Coins"
        }
    }

}

#Preview {
    ShopView(gameViewModel: GameViewModel(), gameData: GameData())
}
