//
//  ShapeUpLogoView.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2021-08-13.
//

import ShapeUp
import SwiftUI

struct ShapeUpLogo: View {
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                // Pink Logo
                CornerCustom { rect in
                    [
                        rect[.topLeft].corner(.straight(.relative(0.27))),
                        rect[0.925, 0.04].corner(.cutout(.relative(0.4))),
                        rect[0.925, 0.3].corner(.rounded(.relative(0.4))),
                        rect[0.005, 0.92].corner(.concave(.relative(0.23)))
                    ]
                        .rotated(.degrees(9))
                        .moved(rect[0.06, 0.02])
                }
                    .fill(Color.suPink)

                    .shadow(color: .suBlack, radius: 0.01, x: proxy.size.width * 0.006, y: proxy.size.width * 0.0076)
                
                /// Purple Logo
                CornerCustom { rect in
                    [
                        rect[.topLeft].corner(.rounded(.relative(0.12))),
                        rect[0.271, 0].corner(.concave(.relative(0.12))),
                        rect[0.271, 1 - 0.15].corner(.straight(.relative(0.18))),
                        rect[0, 1 - 0.15].corner(.rounded(.relative(0.23)))
                    ]
                        .rotated(.degrees(-5))
                        .moved(rect[0.63, 0.11])
                }
                .fill(Color.suPurple)
                
                Group {
                    // Cyan triangle
                    CornerTriangle(topPoint: .relative(0.72))
                        .fill(Color.suCyan)
                        .aspectRatio(0.9, contentMode: .fit)
                        .frame(width: proxy.size.width * 0.075)
                        .rotationEffect(.degrees(-126))
                        .offset(proxy.size.scaled(0.019, 0.35))

                    // Three triangles
                    VStack(spacing: proxy.size.height * 0.026) {
                        Group {
                            CornerTriangle()
                                .fill(Color.suCyan)
                            
                            CornerTriangle()
                                .fill(Color.suPink)
                            
                            CornerTriangle()
                                .fill(Color.suYellow)
                        }
                        .aspectRatio(2, contentMode: .fit)
                        .frame(width: proxy.size.width * 0.06)
                    }
                    .offset(x: proxy.size.width * 0.698, y: proxy.size.height * 0.22)
                    
                    // Yellow Square
                    Rectangle()
                        .fill(Color.suYellow)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: proxy.size.width * 0.041)
                        .rotationEffect(.degrees(15))
                        .offset(proxy.size.scaled(0.8365, 0.17))
                    
                    // Yellow Squiggle
                    CornerCustom(closed: false) { rect in
                        rect[
                            (0.0, 1.0),
                            (1.1, 0),
                            (2.1, 0.9),
                            (2.9, -0.1),
                            (3.8, 1),
                            (5, 0)
                        ]
                            .scaledPositions(x: 0.0365, y: 0.1)
                            .rotated(.degrees(-15), anchor: .bottomLeft)
                            .moved(rect[0.28, 0.23])
                            .corners()
                    }
                    .stroke(Color.suYellow, lineWidth: proxy.size.height * 0.05)
                    
                    // Text
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("S")
                            .font(.custom("Futura-Bold", fixedSize: proxy.size.height * 0.75))
                        
                        Text("HAPE")
                            .font(.custom("Futura-Bold", fixedSize: proxy.size.height * 0.51))
                            .scaleEffect(x: 0.98, y: 1, anchor: .leading)
                            .padding(.leading, proxy.size.width * -0.008)
                        
                        Text("U")
                            .font(.custom("Futura", fixedSize: proxy.size.height * 0.83))
                            .scaleEffect(x: 1.02, y: 1, anchor: .leading)
                            .padding(.top, proxy.size.height * -0.09)
                            .padding(.leading, proxy.size.width * -0.005)
                        
                        Text("P")
                            .font(.custom("Futura", fixedSize: proxy.size.height * 0.51))
                            .padding(.leading, proxy.size.width * -0.008)
                    }
                    .foregroundColor(.suWhite)
                    .offset(x: proxy.size.width * 0.1, y: proxy.size.width * 0.01)
                }
                .shadow(color: .suBlack, radius: 0.001, x: proxy.size.width * 0.007, y: proxy.size.width * 0.004)
            }
            
//            Image("ShapeUp-logo")
//                .resizable()
//                .scaledToFit()
//                .opacity(0.5)
        }
            .aspectRatio(3.5625, contentMode: .fit)
    }
}

struct ShapeUpLogoView: View {
    var body: some View {
        VStack {
            ShapeUpLogo()
            
            Text("Created with ShapeUp shapes and SwiftUI Text.")
        }
        .navigationTitle("Logo")
    }
}

struct ShapeUpLogoView_Previews: PreviewProvider {
    static var previews: some View {
        ShapeUpLogoView()
    }
}
