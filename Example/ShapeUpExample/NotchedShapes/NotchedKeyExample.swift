//
//  NotchedKeyExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2026-07-16.
//

import ShapeUp
import SwiftUI

struct NotchedKeyExample: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CornerCustom { rect in
                    Corners {
                        rect[0.4, 0.65]
                        rect[0.3, 1]
                        rect[0.03, 1]
                        
                        Notch(length: .relative(0.3), depth: .relative(-0.1)) {
                            RelativeCorner.topLeft
                            
                            RelativeCorners {
                                RelativeCorner.bottomLeft
                                RelativeCorner.bottomRight
                            }
                            .scaledPositions(0.7, anchor: .center)
                            
                            RelativeCorner.topRight
                        }
                        .cornerStyle(.straight(radius: .absolute(16)))
                        
                        rect[0.03, 0]
                        rect[0.3, 0]
                        rect[0.4, 0.3]
                        rect[1, 0.3]
                        rect[1, 0.65]
                    }
                    .cornerStyle(.rounded(radius: .absolute(16)))
//                    .changingRadius(to: .relative(0.3))

                    Notch(
                        .triangle,
                        position: .relative(0.3),
                        length: .relative(0.12),
                        depth: .relative(0.05)
                    )
                    .cornerStyle(.rounded(radius: 2))

                    Notch(
                        position: .relative(0.68),
                        length: .relative(0.1),
                        depth: .relative(0.05)
                    )
                    .cornerStyle(.rounded(radius: 3))
                }
                .fill(Color.suYellow)
            }
            .compositingGroup()
        }
        .aspectRatio(2.2, contentMode: .fit)
        .frame(maxWidth: 420)
        .padding()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("A key with three notched grooves")
        .navigationTitle("Notched Key")
    }
}

#Preview {
    NotchedKeyExample()
}
