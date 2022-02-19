//
//  RelatableValueTests.swift
//  
//
//  Created by Ryan Lintott on 2022-02-17.
//

@testable import ShapeUp
import XCTest

class RelatableValueTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRelativeValue() throws {
        // given
        // relative, total, result
        let testValues: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 10, 0),
            (0.1, 10, 1),
            (0.5, 42, 21),
            (0.9, 100, 90)
        ]
        
        testValues.forEach { (relative, total, result) in
            // when
            let value = RelatableValue.relative(relative).value(using: total)
            
            // then
            XCTAssertEqual(value, result)
        }
    }

    func testAbsoluteValue() throws {
        // given
        // absolute, total
        let testValues: [(CGFloat, CGFloat)] = [
            (0, 10),
            (0.1, 10),
            (2, 42),
            (35, 100),
            (600, 23)
        ]
        
        testValues.forEach { (absolute, total) in
            // when
            let value = RelatableValue.absolute(absolute).value(using: total)
            
            // then
            XCTAssertEqual(value, absolute)
        }
    }
    
    func testFloatLiteral() throws {
        XCTAssertEqual(RelatableValue(1.1), .absolute(1.1))
    }
    
    func testIntegerLiteral() throws {
        XCTAssertEqual(RelatableValue(1), .absolute(1))
    }
}
