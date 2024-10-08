//
//  EmbossExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2021-09-16.
//

import ShapeUp
import SwiftUI

struct EmbossExample: View {
    let angle: Angle = .degrees(45)
    let color = Color.suPurple
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Circle()
                    .fill(color)
                    .emboss(using: Circle(), size: 4, angle: angle, opacity: 1)
                    .frame(width: 200)
                
                Image(systemName: "heart")
                    .resizable()
                    .scaledToFit()
                    .deboss(baseColor: color, amount: 1, blur: 1, angle: angle, opacity: 0.3)
                    .frame(width: 200)
                
                Text("Hello World")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(color)
                    .deboss(amount: 0.5, angle: angle, opacity: 0.5)
                
                CornerRectangle([
                    .topLeft: .straight(radius: 60),
                    .topRight: .cutout(radius: .relative(0.2)),
                    .bottomRight: .rounded(radius: .relative(0.6)),
                    .bottomLeft: .concave(radius: .relative(0.2))
                ])
                .embossEdges(size: 2, angle: angle, opacity: 1)
                .padding()
                .background(color)
                .frame(width: 200, height: 200)
                
                CornerPentagon(pointHeight: 20, topTaper: .relative(0.5), bottomTaper: .relative(0.2))
                    .embossEdges(size: 4, angle: angle, opacity: 1)
                    .padding()
                    .background(color)
                    .frame(width: 200, height: 200)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Emboss")
    }
}

struct EmbossExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmbossExample()
        }
    }
}
