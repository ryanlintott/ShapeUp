//
//  RectAnchorArrayTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-03.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class RectAnchorArrayTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRectAnchorArrayPointsMatchRectAnchorPoints() throws {
        // given
        let rect = CGRect(x: -10, y: -20, width: 20, height: 40)
        let rectAnchors = RectAnchor.allCases
        
        // when
        let pointArray = rectAnchors.points(in: rect)
        
        // then
        // Check that both arrays have the same count
        XCTAssertEqual(pointArray.count, rectAnchors.count)
        
        if pointArray.count == rectAnchors.count {
            for i in 0..<pointArray.count {
                // Check that the point value calculated above equals the point value of each element
                XCTAssertEqual(pointArray[i], rectAnchors[i].point(in: rect))
            }
        }
    }

}
