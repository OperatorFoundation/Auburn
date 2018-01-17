//
//  AuburnTests.swift
//  AuburnTests
//
//  Created by Brandon Wiley on 11/29/17.
//  Copyright © 2017 Operator Foundation. All rights reserved.
//

import XCTest
@testable import Auburn

extension String: LosslessStringConvertible {
}

class AuburnTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringDelete() {
        let testString: RString = "cats and dogs together?!??"
        testString.delete()
    }

    func testStringKey() {
        let correct: RString = "cats and dogs together?!??"
        correct.key="testString"
        
        let result: RString = RString(key: "testString")
        XCTAssertEqual(result, correct)
    }
    
    func testListDelete() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.delete()
    }

    func testListCreating() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.key="creating"
        testList.delete()
    }

    func testListMoving() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.key="temp"
        testList.key="moving"
        testList.delete()
    }

    func testListDeleting() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.key="deleting"
        testList.delete()
    }

    func testSequenceIteration() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        let golden: [String] = ["cats", "and", "dogs", "together?!??"]

        for x in 0...3 {
            XCTAssertEqual(testList[x], golden[x])
        }
    }

    func testListInt() {
        let testIntList: RList<Int> = [1, 2, 3, 4]

        let golden: [Int] = [1, 2, 3, 4]

        for x in 0...3 {
            XCTAssertEqual(testIntList[x], golden[x])
        }
    }

    func testMapDelete() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        testMap.delete()
    }

    func testMapCreating() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        testMap.key="creatingMap"
        testMap.delete()
    }

    func testMapMoving() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        testMap.key="tempMap"
        testMap.key="movingMap"
        testMap.delete()
    }

    func testMapIteration() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        var golden: Dictionary<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]

        for itemKey in ["a", "b", "c", "d"] {
            XCTAssertEqual(testMap[itemKey], golden[itemKey])
        }
    }

    func testIntMapIteration() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testMap: RMap<String, Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
        var golden: Dictionary<String, Int> = ["a": 1, "b": 2, "c": 3, "d": 4]

        for itemKey in ["a", "b", "c", "d"] {
            XCTAssertEqual(testMap[itemKey], golden[itemKey])
        }
    }

    func testSetDelete() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testSet: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSet.delete()
    }

    func testSetCreating() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testSet: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSet.key="creatingSet"
        testSet.delete()
    }

    func testSetMoving() {
        let testSet: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSet.key="tempSet"
        testSet.key="movingSet"
        testSet.delete()
    }

    func testSetIteration() {
        let testSet: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        let golden: Set<String> = ["cats", "and", "dogs", "together?!??"]

        // Since this is a set, order is not guaranteed.
        for x in 0...3 {
            XCTAssertTrue(golden.contains(testSet[x]))
        }
    }

    func testSetCount() {
        let testSet: RSet<String> = ["cats", "and", "dogs", "together?!??"]

        XCTAssertEqual(testSet.count, 4)
    }

    func testSetEquality() {
        let testSet1: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSet2: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSet3: RSet<String> = ["a", "b", "c", "d"]

        XCTAssertEqual(testSet1, testSet2)
        XCTAssertNotEqual(testSet2, testSet3)
    }

    func testSetAlgebra() {
        let testRSet1: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testRSet2: RSet<String> = ["cats", "are", "never", "dogs"]
        let testUnion: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testInter: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSymDiff: RSet<String> = ["cats", "and", "dogs", "together?!??"]

        let goldenUnion: RSet<String> = ["cats", "are", "dogs", "and", "never", "together?!??"]
        let goldenInter: RSet<String> = ["cats", "dogs"]
        let goldenSymDiff: RSet<String> = ["and", "are", "never", "together?!??"]

        XCTAssertTrue(testRSet1.contains("cats"))
        XCTAssertFalse(testRSet1.contains("never"))

        XCTAssertEqual(testRSet1.union(testRSet2), goldenUnion)
        XCTAssertEqual(testRSet1.intersection(testRSet2), goldenInter)
        XCTAssertEqual(testRSet1.symmetricDifference(testRSet2), goldenSymDiff)

        testUnion.formUnion(testRSet2)
        testInter.formIntersection(testRSet2)
        testSymDiff.formSymmetricDifference(testRSet2)

        XCTAssertEqual(testUnion, goldenUnion)
        XCTAssertEqual(testInter, goldenInter)
        XCTAssertEqual(testSymDiff, goldenSymDiff)

/*
         Conforming to the SetAlgebra Protocol - from https://developer.apple.com/documentation/swift/setalgebra
         When implementing a custom type that conforms to the SetAlgebra protocol, you must implement the required initializers and methods. For the inherited methods to work properly, conforming types must meet the following axioms. Assume that S is a custom type that conforms to the SetAlgebra protocol, x and y are instances of S, and e is of type S.Element—the type that the set holds.
*/

//         S() == []

        let testEmptySet: RSet<String> = RSet<String>()
        let testEmptyLiteralSet: RSet<String> = []

        XCTAssertEqual(testEmptySet, testEmptyLiteralSet)

//         x.intersection(x) == x

        XCTAssertEqual(testRSet1.intersection(testRSet1), testRSet1)

//         x.intersection([]) == []

        XCTAssertEqual(testRSet1.intersection(testEmptyLiteralSet), testEmptyLiteralSet)

//         x.union(x) == x

        XCTAssertEqual(testRSet1.union(testRSet1), testRSet1)

//         x.union([]) == x

        XCTAssertEqual(testRSet1.union(testEmptyLiteralSet), testRSet1)

//         x.contains(e) implies x.union(y).contains(e)

        for index in 0..<testRSet1.count {
            let e = testRSet1[index]
            XCTAssertTrue(testRSet1.contains(e))
            XCTAssertTrue(testRSet1.union(testRSet2).contains(e))
        }

//         x.union(y).contains(e) implies x.contains(e) || y.contains(e)

        let u = testRSet1.union(testRSet2)
        for index in 0..<u.count {
            let e = u[index]
            XCTAssertTrue(u.contains(e))
            XCTAssertTrue(testRSet1.contains(e) || testRSet2.contains(e))
        }

//         x.contains(e) && y.contains(e) if and only if x.intersection(y).contains(e)

        let inter = testRSet1.intersection(testRSet2)
        for index in 0..<inter.count {
            let e = inter[index]
            XCTAssertTrue(inter.contains(e))
            XCTAssertTrue(testRSet1.contains(e) && testRSet2.contains(e))
        }

        for index in 0..<testRSet1.count {
            let e = testRSet1[index]
            if inter.contains(e) {
                XCTAssertTrue(testRSet1.contains(e) && testRSet2.contains(e))
            } else {
                XCTAssertFalse(testRSet1.contains(e) && testRSet2.contains(e))
            }
        }

        for index in 0..<testRSet2.count {
            let e = testRSet2[index]
            if inter.contains(e) {
                XCTAssertTrue(testRSet1.contains(e) && testRSet2.contains(e))
            } else {
                XCTAssertFalse(testRSet1.contains(e) && testRSet2.contains(e))
            }
        }

//         x.isSubset(of: y) if and only if y.isSuperset(of: x)

        let superset: RSet<String> = ["cats", "and", "dogs", "together?!??", "again?!?!?!"]

        XCTAssertTrue(superset.isSuperset(of: testRSet1))
        XCTAssertTrue(testRSet1.isSubset(of: superset))

        XCTAssertFalse(superset.isSuperset(of: testRSet2))
        XCTAssertFalse(testRSet2.isSubset(of: superset))

        XCTAssertTrue(testRSet2.isSuperset(of: testRSet2))
        XCTAssertTrue(testRSet2.isSubset(of: testRSet2))

//         x.isStrictSuperset(of: y) if and only if x.isSuperset(of: y) && x != y

        XCTAssertTrue(superset.isSuperset(of: testRSet1))
        XCTAssertTrue(superset.isStrictSuperset(of: testRSet1))
        XCTAssertNotEqual(superset, testRSet1)

        XCTAssertNotEqual(testRSet2, superset)
        XCTAssertNotEqual(testRSet2.intersection(superset), testRSet2)
        XCTAssertNotEqual(superset.intersection(testRSet2), superset)

        XCTAssertFalse(superset.isStrictSuperset(of: testRSet2))
        XCTAssertFalse(testRSet2.isStrictSubset(of: superset))

        XCTAssertTrue(testRSet2.isSuperset(of: testRSet2))
        XCTAssertFalse(testRSet2.isStrictSuperset(of: testRSet2))

//         x.isStrictSubset(of: y) if and only if x.isSubset(of: y) && x != y

        XCTAssertTrue(testRSet1.isSubset(of: superset))
        XCTAssertTrue(testRSet1.isStrictSubset(of: superset))

        XCTAssertFalse(testRSet2.isSubset(of: superset))
        XCTAssertFalse(testRSet2.isStrictSubset(of: superset))

        XCTAssertTrue(testRSet2.isSubset(of: testRSet2))
        XCTAssertFalse(testRSet2.isStrictSubset(of: testRSet2))
    }

    func testSortedSetDelete() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testSortedSet: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSortedSet.delete()
    }

    func testSortedSetCreating() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testSortedSet: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSortedSet.key="creatingSortedSet"
        testSortedSet.delete()
    }

    func testSortedSetDictionaryCreating() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testSortedSet: RSortedSet<String> = ["cats": 0, "and": 1, "dogs": 3, "together?!??": 4]
        testSortedSet.key="creatingSortedSet"
        testSortedSet.delete()
    }

    func testSortedSetMoving() {
        let testSortedSet: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSortedSet.key="tempSortedSet"
        testSortedSet.key="movingSortedSet"
        testSortedSet.delete()
    }

    func testSortedSetEquality() {
        let testSortedSet1: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSortedSet2: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSortedSet3: RSortedSet<String> = ["a", "b", "c", "d"]

        XCTAssertEqual(testSortedSet1, testSortedSet2)
        XCTAssertNotEqual(testSortedSet2, testSortedSet3)
    }

    func testSortedSetSubscript() {
        let testSortedSet: RSortedSet<String> = ["cats": 0, "and": 2, "dogs": 4, "together?!??": 8]

        XCTAssertEqual(testSortedSet["and"], 2)
        XCTAssertEqual(testSortedSet[1], "and")
    }

    func testSortedSetAlgebraMethods() {
        let testRSortedSet1: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testRSortedSet2: RSortedSet<String> = ["cats", "are", "never", "dogs"]
        let testUnion: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testInter: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSymDiff: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]

        let goldenUnion: RSortedSet<String> = ["cats", "are", "dogs", "and", "never", "together?!??"]
        let goldenInter: RSortedSet<String> = ["cats", "dogs"]
        let goldenSymDiff: RSortedSet<String> = ["and", "are", "never", "together?!??"]

        XCTAssertTrue(testRSortedSet1.contains(("cats", 0)))
        XCTAssertFalse(testRSortedSet1.contains(("never", 0)))

        XCTAssertEqual(testRSortedSet1.union(testRSortedSet2), goldenUnion)
        XCTAssertEqual(testRSortedSet1.intersection(testRSortedSet2), goldenInter)
        XCTAssertEqual(testRSortedSet1.symmetricDifference(testRSortedSet2), goldenSymDiff)

        testUnion.formUnion(testRSortedSet2)
        testInter.formIntersection(testRSortedSet2)
        testSymDiff.formSymmetricDifference(testRSortedSet2)

        XCTAssertEqual(testUnion, goldenUnion)
        XCTAssertEqual(testInter, goldenInter)
        XCTAssertEqual(testSymDiff, goldenSymDiff)
    }

    func testSortedSetAlgebraAxioms() {
        let testRSortedSet1: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testRSortedSet2: RSortedSet<String> = ["cats", "are", "never", "dogs"]
        let superset: RSortedSet<String> = ["cats", "and", "dogs", "together?!??", "again?!?!?!"]

        /*
         Conforming to the SetAlgebra Protocol - from https://developer.apple.com/documentation/swift/setalgebra
         When implementing a custom type that conforms to the SetAlgebra protocol, you must implement the required initializers and methods. For the inherited methods to work properly, conforming types must meet the following axioms. Assume that S is a custom type that conforms to the SetAlgebra protocol, x and y are instances of S, and e is of type S.Element—the type that the set holds.
         */

        //         S() == []

        let testEmptySet: RSortedSet<String> = RSortedSet<String>()
        let testEmptyLiteralSet: RSortedSet<String> = []

        XCTAssertEqual(testEmptySet, testEmptyLiteralSet)

        //         x.intersection(x) == x

        XCTAssertEqual(testRSortedSet1.intersection(testRSortedSet1), testRSortedSet1)

        //         x.intersection([]) == []

        XCTAssertEqual(testRSortedSet1.intersection(testEmptyLiteralSet), testEmptyLiteralSet)

        //         x.union(x) == x

        XCTAssertEqual(testRSortedSet1.union(testRSortedSet1), testRSortedSet1)

        //         x.union([]) == x

        XCTAssertEqual(testRSortedSet1.union(testEmptyLiteralSet), testRSortedSet1)

        //         x.contains(e) implies x.union(y).contains(e)

        for index in 0..<testRSortedSet1.count {
            let e = testRSortedSet1[index]
            XCTAssertTrue(testRSortedSet1.contains((e, 0)))
            XCTAssertTrue(testRSortedSet1.union(testRSortedSet2).contains((e, 0)))
        }

        //         x.union(y).contains(e) implies x.contains(e) || y.contains(e)

        let u = testRSortedSet1.union(testRSortedSet2)
        for index in 0..<u.count {
            let e = u[index]
            XCTAssertTrue(u.contains((e, 0)))
            XCTAssertTrue(testRSortedSet1.contains((e, 0)) || testRSortedSet2.contains((e, 0)))
        }

        //         x.contains(e) && y.contains(e) if and only if x.intersection(y).contains(e)

        let inter = testRSortedSet1.intersection(testRSortedSet2)
        for index in 0..<inter.count {
            let e = inter[index]
            XCTAssertTrue(inter.contains((e, 0)))
            XCTAssertTrue(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
        }

        for index in 0..<testRSortedSet1.count {
            let e = testRSortedSet1[index]
            if inter.contains((e, 0)) {
                XCTAssertTrue(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
            } else {
                XCTAssertFalse(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
            }
        }

        for index in 0..<testRSortedSet2.count {
            let e = testRSortedSet2[index]
            if inter.contains((e, 0)) {
                XCTAssertTrue(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
            } else {
                XCTAssertFalse(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
            }
        }

        //         x.isSubset(of: y) if and only if y.isSupeRSortedSet(of: x)

        XCTAssertTrue(superset.isSuperset(of: testRSortedSet1))
        XCTAssertTrue(testRSortedSet1.isSubset(of: superset))

        XCTAssertFalse(superset.isSuperset(of: testRSortedSet2))
        XCTAssertFalse(testRSortedSet2.isSubset(of: superset))

        XCTAssertTrue(testRSortedSet2.isSuperset(of: testRSortedSet2))
        XCTAssertTrue(testRSortedSet2.isSubset(of: testRSortedSet2))

        //         x.isStrictSuperset(of: y) if and only if x.isSuperset(of: y) && x != y

        XCTAssertTrue(superset.isSuperset(of: testRSortedSet1))
        XCTAssertTrue(superset.isStrictSuperset(of: testRSortedSet1))
        XCTAssertNotEqual(superset, testRSortedSet1)

        XCTAssertNotEqual(testRSortedSet2, superset)

        XCTAssertNotEqual(testRSortedSet2.intersection(superset), testRSortedSet2)
        XCTAssertNotEqual(superset.intersection(testRSortedSet2), superset)

        XCTAssertFalse(superset.isStrictSuperset(of: testRSortedSet2))
        XCTAssertFalse(testRSortedSet2.isStrictSubset(of: superset))

        XCTAssertTrue(testRSortedSet2.isSuperset(of: testRSortedSet2))
        XCTAssertFalse(testRSortedSet2.isStrictSuperset(of: testRSortedSet2))

        //         x.isStrictSubset(of: y) if and only if x.isSubset(of: y) && x != y

        XCTAssertTrue(testRSortedSet1.isSubset(of: superset))
        XCTAssertTrue(testRSortedSet1.isStrictSubset(of: superset))

        XCTAssertFalse(testRSortedSet2.isSubset(of: superset))
        XCTAssertFalse(testRSortedSet2.isStrictSubset(of: superset))

        XCTAssertTrue(testRSortedSet2.isSubset(of: testRSortedSet2))
        XCTAssertFalse(testRSortedSet2.isStrictSubset(of: testRSortedSet2))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
