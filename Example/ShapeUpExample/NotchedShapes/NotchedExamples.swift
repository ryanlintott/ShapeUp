//
//  NotchedExamples.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-09.
//

import ShapeUp
import SwiftUI

struct NotchedExamples: View {
    var body: some View {
        Section {
            NavigationLink(destination: NotchedRectangleExample()) {
                Label("NotchedRectangle", systemImage: "rectangle")
            }
            
            NavigationLink(destination: NotchedTriangleExample()) {
                Label("NotchedTriangle", systemImage: "triangle")
            }
            
            NavigationLink(destination: NotchedPentagonExample()) {
                Label("NotchedPentagon", systemImage: "pentagon")
            }
        } header: {
            Text("Notched")
        }
    }
}

struct NotchedExamples_Previews: PreviewProvider {
    static var previews: some View {
        NotchedExamples()
    }
}
