//
//  BackgroundRectangle.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import SwiftUI

struct BackgroundRectangle: View {
    var body: some View {
        
        GeometryReader{ g in
            HStack{
                Spacer()
                ZStack(alignment: .center){
                    Image("miniGames")
                        .resizable()
                        .frame(width: g.size.width * 0.8)
                    
                    Image("rec")
                        .resizable()
                        .frame(width: g.size.width * 0.7, height: g.size.height * 0.8)
                    
                }
                Spacer()
            }
        }

    }
}

#Preview {
    BackgroundRectangle()
}
