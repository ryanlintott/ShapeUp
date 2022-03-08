//
//  CornerStyle+CutoutLocation.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-10.
//

import Foundation


internal extension CornerStyle {
    /// An enumeration representing the cutout location on cutout style corners.
    ///
    /// Not in use yet.
    enum CutoutLocation {
        /// The center of the corner radius.
        case radiusCenter
        /// A point opposite the corner point across the line from corner start to corner end.
        case mirrorPoint
        /// The shallowest cut between radius center and mirror point.
        case shallow
        /// The deepest cut between radius center and mirror point.
        case deep
    }
}
