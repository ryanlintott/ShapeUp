//
//  Vector2RepresentableArrayTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-03.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class Vector2RepresentableArrayTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    fileprivate static let testVectors: [Vector2] = [
        (0.0,0.0),
        (30,20),
        (-2.2,30),
        (-2.2,-5)
    ].map { Vector2(dx: $0.0, dy: $0.1) }
    
    fileprivate static let testMatchingRect = CGRect(x: -2.2, y: -5, width: 32.2, height: 35)
    
    func testVector2ArrayBoundsMatchCGRect() throws {
        XCTAssertEqual(Self.testVectors.bounds, Self.testMatchingRect)
    }
    
    func testAnchorPointMatchesBoundsAnchorPoint() throws {
        RectAnchor.allCases.forEach { rectAnchor in
            XCTAssertEqual(
                Self.testVectors.anchorPoint(rectAnchor),
                Self.testVectors.bounds[rectAnchor]
            )
        }
    }
    
    func testCenterMatchesAnchorPointCenter() throws {
        XCTAssertEqual(
            Self.testVectors.center,
            Self.testVectors.anchorPoint(.center)
        )
    }
}
