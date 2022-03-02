//
//  GeoMathTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-28.
//

@testable import ShapeUp
import SwiftUI
import XCTest

class GeoMathTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLineIntersectsCircleTwice() throws {
        // Given
        let point1 = CGPoint(x: 2, y: 1)
        let point2 = CGPoint(x: 3, y: 2)
        let center = CGPoint(x: 4, y: 0)
        let radius = 3.0
        
        // When
        let intersectionPoints = GeoMath.intersectionPoints(line: (point1: point1, point2: point2), circle: (center: center, radius: radius))
        
        // Then
        XCTAssertTrue(intersectionPoints.count == 2)
        XCTAssertTrue(intersectionPoints.contains(where: { $0 == CGPoint(x: 1, y: 0)}))
        XCTAssertTrue(intersectionPoints.contains(where: { $0 == CGPoint(x: 4, y: 3)}))
    }
    
    func testHorizontalLineIntersectsCircleOnce() throws {
        // Given
        let point1 = CGPoint(x: 6, y: 3)
        let point2 = CGPoint(x: 2, y: 3)
        let center = CGPoint(x: 2, y: 1)
        let radius = 2.0
        
        // When
        let intersectionPoints = GeoMath.intersectionPoints(line: (point1: point1, point2: point2), circle: (center: center, radius: radius))
        
        // Then
        XCTAssertEqual(intersectionPoints, [CGPoint(x: 2, y: 3)])
    }
    
    func testVerticalLineIntersectsCircleOnce() throws {
        // Given
        let point1 = CGPoint(x: 3, y: 6)
        let point2 = CGPoint(x: 3, y: 1)
        let center = CGPoint(x: 1, y: 3)
        let radius = 2.0
        
        // When
        let intersectionPoints = GeoMath.intersectionPoints(line: (point1: point1, point2: point2), circle: (center: center, radius: radius))
        
        // Then
        XCTAssertEqual(intersectionPoints, [CGPoint(x: 3, y: 3)])
    }
    
    func testNoInstersections() throws {
        // Given
        let point1 = CGPoint(x: 1, y: 1)
        let point2 = CGPoint(x: 2, y: 3)
        let center = CGPoint(x: 4, y: 1)
        let radius = 2.5
        
        // When
        let intersectionPoints = GeoMath.intersectionPoints(line: (point1: point1, point2: point2), circle: (center: center, radius: radius))
        
        // Then
        XCTAssertEqual(intersectionPoints, [])
    }
}
