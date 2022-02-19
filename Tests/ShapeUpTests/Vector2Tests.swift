//
//  Vector2Tests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-02.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class Vector2Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    fileprivate static let testPoints: [(x: CGFloat, y: CGFloat)] = [
        (0,0),
        (0,1),
        (1,0),
        (1,1),
        (-1,2),
        (2,-1),
        (1.2345,9.1234)
    ]
    
    func testZeroIsZero() throws {
        // given
        let vector = Vector2.zero
        
        // when
        let x = vector.dx
        let y = vector.dy
        
        // then
        XCTAssertEqual(x, 0)
        XCTAssertEqual(y, 0)
    }
    
    func testSizeMatchesVector2() throws {
        Self.testPoints.forEach { (x, y) in
            // given
            let vector = Vector2(dx: x, dy: y)
            
            // when
            let size = CGSize(width: x, height: y)
            
            // then
            XCTAssertEqual(vector.size, size)
        }
    }
    
    func testCGRectMatchesVector2() throws {
        Self.testPoints.forEach { (x, y) in
            // given
            let vector = Vector2(dx: x, dy: y)
            
            // when
            let rect = CGRect(x: 0, y: 0, width: x, height: y)
            
            // then
            XCTAssertEqual(vector.rect, rect)
        }
    }
    
    func testRepositionedToVector2() throws {
        Self.testPoints.forEach { (x1, y1) in
            Self.testPoints.forEach { (x2, y2) in
                // given
                let v1 = Vector2(dx: x1, dy: y1)
                let v2 = Vector2(dx: x2, dy: y2)
                
                // when
                let repositioned = v1.repositioned(to: v2)
                
                // then
                XCTAssertEqual(repositioned, v2)
            }
        }
    }
}
