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
    @State var boughtSkinId: [Int] = [1]
    @State var boughtLocId: [Int] = [1]

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
                            .frame(width: g.size.width * 0.8)
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
                                    .padding(.bottom, 20)
                                ,alignment: .bottom
                            )
                        
                    } else {
                        Image("desertLocation")
                            .resizable()
                            .scaledToFit()
                            .frame(width: g.size.width * 0.8)
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
                                    .padding(.bottom, 20)
                                ,alignment: .bottom
                            )

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
        if boughtSkinId.contains(id) {
            gameViewModel.eagleSkin = "eagle\(id)"
        } else {
            if gameData.coins >= 100 {
                gameData.coins -= 100
                boughtSkinId.append(id)
                gameViewModel.eagleSkin = "eagle\(id)"
            } else {
                print("Not enough money")
            }
        }
    }
    
    private func handleLocationButton(id: Int) {
        if boughtLocId.contains(id) {
            gameViewModel.backgroundImage = "loc\(id)"
        } else {
            if gameData.coins >= 100 {
                gameData.coins -= 100

                boughtLocId.append(id)
                gameViewModel.backgroundImage = "loc\(id)"
            } else {
                print("Not enough money")

            }
        }
    }
    
    private func currentSkinButtonImage(for id: Int) -> String {
        if gameViewModel.eagleSkin == "eagle\(id)" {
            return "Use"
        } else if boughtSkinId.contains(id) {
            return "Use"
        } else {
            return "100Coins"
        }
    }
    
    private func currentLocButtonImage(for id: Int) -> String {
        if gameViewModel.backgroundImage == "loc\(id)" {
            return "Use"
        } else if boughtLocId.contains(id) {
            return "Use"
        } else {
            return "100Coins"
        }
    }

}

#Preview {
    ShopView(gameViewModel: GameViewModel(), gameData: GameData())
}
