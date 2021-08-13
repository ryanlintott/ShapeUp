//
//  Alignment-extension.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-04-21.
//

import SwiftUI

public extension Alignment {
    static func firstTextBaseline(_ horizontal: HorizontalAlignment = .center) -> Alignment {
        Alignment(horizontal: horizontal, vertical: .firstTextBaseline)
    }
    
    static func lastTextBaseline(_ horizontal: HorizontalAlignment = .center) -> Alignment {
        Alignment(horizontal: horizontal, vertical: .lastTextBaseline)
    }
}
