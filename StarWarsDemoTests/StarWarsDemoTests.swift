//
//  StarWarsDemoTests.swift
//  StarWarsDemoTests
//
//  Created by Pavel Kazantsev on 08/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit
import StarWarsDemo
import XCTest

class StarWarsDemoTests: XCTestCase {

    func testSwdContains() {
        let testData = [1, 3, 4, 9, 8, 12]

        XCTAssertTrue(swd_contains(testData, 1), "Data contain 1")
        XCTAssertTrue(swd_contains(testData, 3), "Data contain 3")
        XCTAssertTrue(swd_contains(testData, 9), "Data contain 9")
        XCTAssertTrue(swd_contains(testData, 12), "Data contain 12")
        XCTAssertFalse(swd_contains(testData, 2), "Data does no cotain 2")
        XCTAssertFalse(swd_contains(testData, 5), "Data does no cotain 5")
    }

    func testSwdIntersect() {
        let testData1 = [1, 3, 4, 9, 8, 12]
        let testData2 = [4, 8, 5, 11]

        let result1 = swd_intersect(testData1, testData2)
        XCTAssertTrue(swd_contains(result1, 4), "Intersection contains 4")
        XCTAssertTrue(swd_contains(result1, 8), "Intersection contains 8")
        XCTAssertFalse(swd_contains(result1, 9), "Intersection does not contain 9")

        let testData3 = [15, 44, 7, 132]
        let testData4 = [12, 132, 44, 88]

        let result2 = swd_intersect(testData3, testData4)
        XCTAssertTrue(swd_contains(result2, 44), "Intersection contains 44")
        XCTAssertTrue(swd_contains(result2, 132), "Intersection contains 132")
        XCTAssertFalse(swd_contains(result1, 15), "Intersection does not contain 15")
    }

    func testSwdSubstract() {
        let testData1 = [1, 3, 4, 9, 8, 12]
        let testData2 = [4, 9, 12]

        let result1 = swd_substract(testData1, testData2)
        XCTAssertTrue(result1 == [1, 3, 8], "Array after substraction should be [1, 3, 8, 12]")

        let testData3 = [15, 33, 7, 4, 1, 144]
        let testData4 = [4, 22, 144, 128]
        let result2 = swd_substract(testData3, testData4)
        XCTAssertTrue(result2 == [15, 33, 7, 1], "Array after substraction should be [15, 33, 7, 4, 1]")
    }
    
}
