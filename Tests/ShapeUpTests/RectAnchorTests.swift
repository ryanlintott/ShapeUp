//
//  RectAnchorTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-03.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class RectAnchorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCasesMatchPointsInCGRect() throws {
        // given
        let rect = CGRect(x: -10, y: -20, width: 20, height: 40)
        let topLeftPoint = CGPoint(x: -10, y: -20)
        let topPoint = CGPoint(x: 0, y: -20)
        let topRightPoint = CGPoint(x: 10, y: -20)
        let leftPoint = CGPoint(x: -10, y: 0)
        let centerPoint = CGPoint(x: 0, y: 0)
        let rightPoint = CGPoint(x: 10, y: 0)
        let bottomLeftPoint = CGPoint(x: -10, y: 20)
        let bottomPoint = CGPoint(x: 0, y: 20)
        let bottomRightPoint = CGPoint(x: 10, y: 20)
        
        // then
        XCTAssertEqual(RectAnchor.topLeft.point(in: rect), topLeftPoint)
        XCTAssertEqual(RectAnchor.top.point(in: rect), topPoint)
        XCTAssertEqual(RectAnchor.topRight.point(in: rect), topRightPoint)
        XCTAssertEqual(RectAnchor.left.point(in: rect), leftPoint)
        XCTAssertEqual(RectAnchor.center.point(in: rect), centerPoint)
        XCTAssertEqual(RectAnchor.right.point(in: rect), rightPoint)
        XCTAssertEqual(RectAnchor.bottomLeft.point(in: rect), bottomLeftPoint)
        XCTAssertEqual(RectAnchor.bottom.point(in: rect), bottomPoint)
        XCTAssertEqual(RectAnchor.bottomRight.point(in: rect), bottomRightPoint)
    }
    
    func testCasesMatchAnchorType() throws {
        XCTAssertEqual(RectAnchor.topLeft.type, .vertex)
        XCTAssertEqual(RectAnchor.top.type, .edge)
        XCTAssertEqual(RectAnchor.topRight.type, .vertex)
        XCTAssertEqual(RectAnchor.left.type, .edge)
        XCTAssertEqual(RectAnchor.center.type, .center)
        XCTAssertEqual(RectAnchor.right.type, .edge)
        XCTAssertEqual(RectAnchor.bottomLeft.type, .vertex)
        XCTAssertEqual(RectAnchor.bottom.type, .edge)
        XCTAssertEqual(RectAnchor.bottomRight.type, .vertex)
    }
    
    func testVerticesArrayIsClockwiseFromTopLeft() throws {
        XCTAssertEqual(RectAnchor.vertices, [.topLeft, .topRight, .bottomRight, .bottomLeft])
    }
}
