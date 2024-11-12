//
//  Vector2RepresentableTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-02.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class Vector2RepresentableTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    fileprivate static let testVectors: [Vector2] = [
        (0.0,0.0),
        (0,1),
        (1,0),
        (1,1),
        (-1,2),
        (2,-1),
        (1.2345,9.1234)
    ].map { Vector2(dx: $0.0, dy: $0.1) }
    
    fileprivate struct V2RTest: Vector2Representable {
        var vector: Vector2
    }
    
    func testV2RMatchesVector2() throws {
        Self.testVectors.forEach { vector in
            // given
            let v2r = V2RTest(vector: vector)
            
            // then
            XCTAssertEqual(v2r.vector, vector)
        }
    }
    
    func testV2RPointMatchesPoint() throws {
        Self.testVectors.forEach { vector in
            // given
            let v2r = V2RTest(vector: vector)
            let point = CGPoint(x: vector.dx, y: vector.dy)
            
            // then
            XCTAssertEqual(v2r.point, point)
        }
    }
    
    func testVector2CornerMatchesCornerDefaultStyle() throws {
        Self.testVectors.forEach { vector in
            // given
            let v2r = V2RTest(vector: vector)
            let corner = Corner(vector: vector)
            
            // then
            XCTAssertEqual(v2r.corner(), corner)
        }
    }
    
    func testVector2CornerMatchesCorner() throws {
        Self.testVectors.forEach { vector in
            // given
            let cornerStyle = CornerStyle.rounded(5)
            let corner = Corner(cornerStyle, x: vector.dx, y: vector.dy)
            
            // then
            XCTAssertEqual(vector.corner(cornerStyle), corner)
        }
    }
}
