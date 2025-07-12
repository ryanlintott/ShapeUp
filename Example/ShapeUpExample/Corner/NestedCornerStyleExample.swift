//
//  NestedCornerStyleExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-09.
//

import ShapeUp
import SwiftUI

struct NestedCornerStyleExample: View {
    let straightCutout: CornerStyle = {
        let radius = RelatableValue.relative(0.25)
        
        return CornerStyle.straight(radius: radius, cornerStyle: .cutout(radius: radius))
    }()
    
    let cutoutStraight: CornerStyle = {
        let radius = RelatableValue.relative(0.3)
        
        return CornerStyle.cutout(radius: radius, cornerStyle: .straight(radius: radius))
    }()
    
    var body: some View {
        VStack {
            Text("Some `CornerStyle` options like `.straight` and `.cutout` create more corners. These corners can also have corner styles applied to them to create detailed nested corners.")
            
            Spacer()
            
            CornerTriangle()
                .applyingStyle(straightCutout)
                .strokeBorder(Color.suPink, lineWidth: 8)
                .frame(width: 150, height: 150)
            
            Spacer()
            
            CornerPentagon(pointHeight: .relative(0.3), bottomTaper: .relative(0.2))
                .applyingStyle(cutoutStraight)
                .strokeBorder(Color.suCyan, lineWidth: 8)
                .frame(width: 150, height: 150)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Nested Corners")
    }
}

struct NestedCornerStyleExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NestedCornerStyleExample()
        }
    }
}
