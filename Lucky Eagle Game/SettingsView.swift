//
//  SettingsView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        GeometryReader { g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: -10){
                    HStack{
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("crossButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.12)
                            
                        }
                        .frame(width: g.size.width * 0.8)

                    }
                    
                    ZStack(alignment: .center){
                        Image("Settings")
                            .resizable()
                            .scaledToFit()
                            .frame(width: g.size.width * 0.8)
                        HStack(spacing: 80){
                            Image("Group 31")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.18)

                            Image("Group 30")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.09)

                            Image("Group 29")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.07)


                        }
                        .padding(.bottom, g.size.height * 0.08)
                        .frame(width: g.size.width * 0.8)

                        
                    }
                }
                .padding(.bottom, g.size.height * 0.3)

            }
        }
        .navigationBarBackButtonHidden()

    }
}

#Preview {
    SettingsView()
}
