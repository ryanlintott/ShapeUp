//
//  HexagonExample.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2022-03-28.
//

import ShapeUp
import SwiftUI

struct QuickHexagonExample: View {
    /// This property cannot be animated as it goes in the CornerCustom closure
    let taper: CGFloat
    
    var body: some View {
            CornerCustom { rect in
                rect[
                    (taper, 0),
                    (1 - taper, 0),
                    (1, 0.5),
                    (1 - taper, 1),
                    (taper, 1),
                    (0, 0.5)
                ]
                    .corners(.rounded(20))
            }
    }
}

struct AdjustableQuickHexagonExample: View {
    @State private var taper = 0.25
    
    var body: some View {
        VStack {
            QuickHexagonExample(taper: taper)
                .aspectRatio(1.1, contentMode: .fit)
            
            CrossPlatformSlider(
                label: "Taper",
                value: $taper,
                minValue: 0,
                maxValue: 0.5,
                step: 0.1
            )
        }
        .padding()
    }
}

struct HexagonExample_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            AdjustableQuickHexagonExample()
        }
    }
}
