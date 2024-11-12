//
//  AddOpenCornerShapeExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-02-11.
//

import ShapeUp
import SwiftUI

struct OpenCornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        let corners = rect[.topLeft, .center, .topRight, .right]
            .corners([
                .straight(.relative(0.2)),
                .cutout(.relative(0.2), cornerStyles: [
                    .rounded(.relative(0.4)),
                    .point,
                    .straight(.relative(0.4))
                ]),
                .cutout(.relative(0.2), cornerStyles: [.rounded(.relative(0.2))]),
                .rounded(20)
            ])
        
        var path = Path()
        path.move(to: rect[0.25, 1])
        path.addQuadCurve(
            to: rect[.left],
            control: rect[.center]
        )
        
        path.addOpenCornerShape(
            corners,
            previousPoint: path.currentPoint,
            nextPoint: rect[.center],
            moveToStart: false
        )
        
        path.addQuadCurve(
            to: rect[0.75, 1],// .point(relativeLocation: (0.75, 1)),
            control: rect[.center]
        )

        return path
    }
}

struct AddOpenCornerShapeExample: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("`CornerShape` does not currently support curves but you can always use an array of `Corner` to draw a part of your path.")
                
                Text("Below is a SwiftUI `Shape` but some of the difficult corner details were added with `path.addOpenCornerShape()`")
            }
            
            Spacer()
            
            OpenCornerShape()
                .stroke(Color.suPink, lineWidth: 10)
                .frame(width: 200, height: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("AddOpenCornerShape")
    }
}

struct AddOpenCornerShapeExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddOpenCornerShapeExample()
        }
    }
}
