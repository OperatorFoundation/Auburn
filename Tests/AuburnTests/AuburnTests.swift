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

class AuburnTests: XCTestCase
{
    
    func testStringDelete()
    {
        let testString: RString = "cats and dogs together?!??"
        testString.delete()
    }

    func testStringKey()
    {
        let correct: RString = "cats and dogs together?!??"
        correct.key="testString"
        
        let result: RString = RString(key: "testString")
        XCTAssertEqual(result, correct)
    }
    
    func testListDelete()
    {
        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.delete()
    }

    func testListCreating()
    {
        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.key="creating"
        testList.delete()
    }
    
    func testListCount()
    {
        let bugs: RList<String> = ["Aphid", "Bumblebee", "Cicada", "Damselfly", "Earwig"]
        bugs.key = "TestListCountBugs"
        
        XCTAssertEqual(bugs.count, 5)
    }
    
    func testListRemoveFirst()
    {
        let bugs: RList<String> = ["Aphid", "Bumblebee", "Cicada", "Damselfly", "Earwig"]
        bugs.key = "TestListBugs"
        
        let goldenBugs = ["Bumblebee", "Cicada", "Damselfly", "Earwig"]
        let firstBug = bugs.removeFirst()
        
        XCTAssertEqual(firstBug, "Aphid")
        XCTAssertTrue(bugs.count == 4)
        for x in 0..<bugs.count
        {
            XCTAssertEqual(goldenBugs[x], bugs[x])
        }
    }

    func testListMoving()
    {
        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.key="temp"
        testList.key="moving"
        testList.delete()
    }

    func testListDeleting()
    {
        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        testList.key="deleting"
        testList.delete()
    }

    func testSequenceIteration()
    {
        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        let golden: [String] = ["cats", "and", "dogs", "together?!??"]

        for x in 0...3 {
            XCTAssertEqual(testList[x], golden[x])
        }
    }

    func testListInt()
    {
        let testIntList: RList<Int> = [1, 2, 3, 4]

        let golden: [Int] = [1, 2, 3, 4]

        for x in 0...3 {
            XCTAssertEqual(testIntList[x], golden[x])
        }
    }

    func testMapDelete()
    {
        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        testMap.delete()
    }

    func testMapCreating()
    {
        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        testMap.key="creatingMap"
        testMap.delete()
    }

    func testMapMoving()
    {
        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        testMap.key="tempMap"
        testMap.key="movingMap"
        testMap.delete()
    }

    func testStringMapIteration()
    {
        let testMap: RMap<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]
        var golden: Dictionary<String, String> = ["a": "cats", "b": "and", "c": "dogs", "d": "together?!??"]

        for itemKey in ["a", "b", "c", "d"]
        {
            XCTAssertEqual(testMap[itemKey], golden[itemKey])
        }
        
        testMap.delete()
    }

    func testIntMapIteration()
    {
        let testMap: RMap<String, Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
        var golden: Dictionary<String, Int> = ["a": 1, "b": 2, "c": 3, "d": 4]

        for itemKey in ["a", "b", "c", "d"]
        {
            XCTAssertEqual(testMap[itemKey], golden[itemKey])
        }
        
        testMap.delete()
    }
    
//    func testFloatMapIteration()
//    {
//        let testMap: RMap<String, Float> = ["a": 1, "b": 2, "c": 3, "d": 4]
//        var golden: Dictionary<String, Float> = ["a": 1, "b": 2, "c": 3, "d": 4]
//        
//        for itemKey in ["a", "b", "c", "d"]
//        {
//            XCTAssertEqual(testMap[itemKey], golden[itemKey])
//        }
//        
//        testMap.delete()
//    }
    
    func testMapSubscript()
    {
        let dataValue = Data(count: 12)
        let anotherDataValue = Data(count: 8)
        let aKeyString = "aFieldKeyString"
        let bKeyString = "bFieldKeyString"
        
        let testMap: RMap<String, Data> = [aKeyString: dataValue]
        testMap.key = "testingRMapData"
        testMap[bKeyString] = anotherDataValue
        
        let swiftDictionary: Dictionary<String, Data> = [aKeyString: dataValue]

        XCTAssertEqual(testMap[aKeyString], swiftDictionary[aKeyString])
        
        XCTAssertEqual(testMap[bKeyString], anotherDataValue)
    }
    
    func testMapIncrement()
    {
        let field1Key = "Oak"
        let field2Key = "Cypress"
        let field3Key = "Willow"
        
        let testMap: RMap<String, Int> = [field1Key: 1, field2Key: 4, field3Key: 7]
        testMap.key = "TestMapIncrby"
        
        let newScore = testMap.increment(field: field1Key)
        
        XCTAssertNotNil(newScore)
        XCTAssertEqual(newScore!, 2)
    }

    func testSetDelete()
    {
        let testSet: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSet.delete()
    }

    func testSetCreating() {
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

    func testSetIteration()
    {
        let testSet: RSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSet.key = "testSetIteration"
        let golden: Set<String> = ["cats", "and", "dogs", "together?!??"]

        // Since this is a set, order is not guaranteed.
        for x in 0..<testSet.count
        {
            guard testSet[x] != nil
            else
            {
                XCTFail("Nothing to be found at index \(x)")
                print("Test Set: \(testSet)")
                print("Golden: \(golden)")
                return
            }
            
            XCTAssertTrue(golden.contains(testSet[x]!))
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

        for index in 0..<testRSet1.count
        {
            guard let e = testRSet1[index]
            else
            {
                XCTFail()
                return
            }
            XCTAssertTrue(testRSet1.contains(e))
            XCTAssertTrue(testRSet1.union(testRSet2).contains(e))
        }

//         x.union(y).contains(e) implies x.contains(e) || y.contains(e)

        let u = testRSet1.union(testRSet2)
        for index in 0..<u.count
        {
            guard let e = u[index]
            else
            {
                XCTFail()
                return
            }
            
            XCTAssertTrue(u.contains(e))
            XCTAssertTrue(testRSet1.contains(e) || testRSet2.contains(e))
        }

//         x.contains(e) && y.contains(e) if and only if x.intersection(y).contains(e)

        let inter = testRSet1.intersection(testRSet2)
        for index in 0..<inter.count
        {
            guard let e = inter[index]
            else
            {
                XCTFail()
                return
            }
            XCTAssertTrue(inter.contains(e))
            XCTAssertTrue(testRSet1.contains(e) && testRSet2.contains(e))
        }

        for index in 0..<testRSet1.count
        {
            guard let e = testRSet1[index]
            else
            {
                XCTFail()
                return
            }
            if inter.contains(e)
            {
                XCTAssertTrue(testRSet1.contains(e) && testRSet2.contains(e))
            }
            else
            {
                XCTAssertFalse(testRSet1.contains(e) && testRSet2.contains(e))
            }
        }

        for index in 0..<testRSet2.count
        {
            guard let e = testRSet2[index]
            else
            {
                XCTFail()
                return
            }
            
            if inter.contains(e)
            {
                XCTAssertTrue(testRSet1.contains(e) && testRSet2.contains(e))
            }
            else
            {
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

    func testSortedSetDelete()
    {
        let testSortedSet: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSortedSet.delete()
    }

    func testSortedSetCreating()
    {
                let testSortedSet: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSortedSet.key="creatingSortedSet"
        testSortedSet.delete()
    }

    func testSortedSetDictionaryCreating()
    {
        let testSortedSet: RSortedSet<String> = ["cats": 0, "and": 1, "dogs": 3, "together?!??": 4]
        testSortedSet.key="creatingSortedSet"
        testSortedSet.delete()
    }
    
    func testSortedSetIncrement()
    {
        let field1Key = "Oak"
        let field2Key = "Cypress"
        let field3Key = "Willow"
        
        let testSortedSet: RSortedSet<String> = [field1Key: 1, field2Key: 4, field3Key: 7]
        testSortedSet.key = "TestSortedSetIncrby"
        
        let newScore = testSortedSet.incrementScore(ofField: field1Key, byIncrement: 1)
        
        XCTAssertNotNil(newScore)
        XCTAssertEqual(newScore!, 2)
    }

    func testSortedSetMoving()
    {
        let testSortedSet: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        testSortedSet.key="tempSortedSet"
        testSortedSet.key="movingSortedSet"
        testSortedSet.delete()
    }

    func testSortedSetEquality()
    {
        let testSortedSet1: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSortedSet2: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testSortedSet3: RSortedSet<String> = ["a", "b", "c", "d"]

        XCTAssertEqual(testSortedSet1, testSortedSet2)
        XCTAssertNotEqual(testSortedSet2, testSortedSet3)
    }

    func testSortedSetSubscript()
    {
        let testSortedSet: RSortedSet<String> = ["cats": 0, "and": 2, "dogs": 4, "together?!??": 8]
        testSortedSet.key = "testSortedSetSubscript"
        
        XCTAssertEqual(testSortedSet["and"], 2)
        XCTAssertEqual(testSortedSet[1], "and")
    }
    
    func testSortedSetGetLongestSequence()
    {
        let testSortedSet: RSortedSet<String> = ["cats": 2, "and": 1, "dogs": 2, "together?!??": 2]
        testSortedSet.key="creatingSortedSet"
        
        guard let result = testSortedSet.getLongestSequence(withScore: 2)
            else
        {
            XCTFail()
            return
        }
        
        XCTAssert(result == "together?!??")
        testSortedSet.delete()
    }
    
    func testSortedSetElementsWithScore()
    {
        let testSortedSet: RSortedSet<String> = ["cats": 2, "and": 1, "dogs": 2, "together?!??": 4]
        testSortedSet.key="creatingSortedSet"
        let results = testSortedSet.getElements(withMinScore: 2, andMaxScore: 2)
        XCTAssert(results?.count == 2)
        XCTAssertTrue(results!.contains("cats"))
         XCTAssertTrue(results!.contains("dogs"))
        testSortedSet.delete()
    }
    
    func testSortedSetFirstAndLast()
    {
        let catsString = "cats"
        let andString = "and"
        let dogsString = "dogs"
        let togetherString = "together?!??"
        let stringSetKey = "stringSortedSet"
        let dataSetKey = "dataSortedSet"
        let intSetKey = "intSortedSet"
        
        let stringSortedSet: RSortedSet<String> = [catsString: 0, andString: 2, dogsString: 4, togetherString: 8]
        stringSortedSet.key = stringSetKey
        XCTAssertEqual(stringSortedSet.last?.0, togetherString)
        XCTAssertEqual(stringSortedSet.last?.1, 8)
        XCTAssertEqual(stringSortedSet.first?.0, catsString)
        XCTAssertEqual(stringSortedSet.first?.1, 0)
        
        //TODO: Issue here with string to data conversion
        // sorted set sees both catsString.data and dogsString.data as the same key
        print("\nCats String is a data!: \(catsString.data) 🐈 🐈 🐈")
        print("Dogs String is a data!: \(dogsString.data) 🐕 🐕 🐕")
        print("Fix me <3\n")
        
        let dataSortedSet: RSortedSet<Data> = [catsString.data: 0, andString.data: 2, dogsString.data(using: String.Encoding.utf8)!: 4, togetherString.data: 8]
        dataSortedSet.key = dataSetKey
        XCTAssertEqual(dataSortedSet.first?.1, 0)
        XCTAssertEqual(dataSortedSet.last?.1, 8)
        
        let intSortedSet: RSortedSet<Int> = [2: 2, 1: 0, 3: 4, 4: 8]
        intSortedSet.key = intSetKey
        XCTAssertEqual(intSortedSet.last?.0, 4)
        XCTAssertEqual(intSortedSet.last?.1, 8)
        XCTAssertEqual(intSortedSet.first?.0, 1)
        XCTAssertEqual(intSortedSet.first?.1, 0)
    }
    
    func testSortedSetWeightedUnion()
    {
        let testRSortedSet1: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testRSortedSet2: RSortedSet<String> = ["cats", "are", "never", "dogs"]
        let goldenUnion: RSortedSet<String> = ["cats", "are", "dogs", "and", "never", "together?!??"]
        
        XCTAssertEqual(testRSortedSet1.weightedUnion(testRSortedSet2, weight: 0.5, otherWeight: 2), goldenUnion)
    }
    
    func testSortedSetInitWithUnion()
    {
        let testRSortedSet1: RSortedSet<String> = ["cats", "and", "dogs", "together?!??"]
        let testRSortedSet2: RSortedSet<String> = ["cats", "are", "never", "dogs"]
        let goldenUnion: RSortedSet<String> = ["cats", "are", "dogs", "and", "never", "together?!??"]
        let newSet: RSortedSet<String> = RSortedSet(unionOf: testRSortedSet1.key, scoresMultipliedBy: 0.5, secondSetKey: testRSortedSet2.key, scoresMultipliedBy: 2, newSetKey: "NewSetFromUnionKey")
        
        XCTAssertEqual(newSet, goldenUnion)
        testRSortedSet1.delete()
        testRSortedSet2.delete()
        newSet.delete()
    }

    func testSortedSetAlgebraMethods()
    {
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

    func testSortedSetAlgebraAxioms()
    {
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

        for index in 0..<testRSortedSet1.count
        {
            guard let e = testRSortedSet1[index]
            else
            {
                XCTFail()
                return
            }
            
            XCTAssertTrue(testRSortedSet1.contains((e, 0)))
            XCTAssertTrue(testRSortedSet1.union(testRSortedSet2).contains((e, 0)))
        }

        //         x.union(y).contains(e) implies x.contains(e) || y.contains(e)

        let u = testRSortedSet1.union(testRSortedSet2)
        for index in 0 ..< u.count
        {
            guard let e = u[index]
                else
            {
                print("\nu index \(index) out of range for set length of \(u.count).\n")
                XCTFail()
                return
            }
            XCTAssertTrue(u.contains((e, 0)))
            XCTAssertTrue(testRSortedSet1.contains((e, 0)) || testRSortedSet2.contains((e, 0)))
        }

        //         x.contains(e) && y.contains(e) if and only if x.intersection(y).contains(e)

        let inter = testRSortedSet1.intersection(testRSortedSet2)
        for index in 0..<inter.count
        {
            guard let e = inter[index]
                else
            {
                print("\ntinter index \(index) out of range for set length of \(inter.count).\n")
                XCTFail()
                return
            }
            XCTAssertTrue(inter.contains((e, 0)))
            XCTAssertTrue(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
        }

        for index in 0..<testRSortedSet1.count
        {
            guard let e = testRSortedSet1[index]
                else
            {
                print("\ntestRSortedSet1 index \(index) out of range for set length of \(testRSortedSet1.count).\n")
                XCTFail()
                return
            }
            
            if inter.contains((e, 0))
            {
                XCTAssertTrue(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
            }
            else
            {
                XCTAssertFalse(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
            }
        }

        for index in 0..<testRSortedSet2.count
        {
            guard let e = testRSortedSet2[index]
                else
            {
                print("\ntestRSortedSet2 index \(index) out of range for set length of \(testRSortedSet2.count).\n")
                XCTFail()
                return
            }
            
            if inter.contains((e, 0))
            {
                XCTAssertTrue(testRSortedSet1.contains((e, 0)) && testRSortedSet2.contains((e, 0)))
            }
            else
            {
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
    
    func testTransactions()
    {
        let testList: RList<String> = ["cats", "and", "dogs", "together?!??"]
        let result = Auburn.transaction {
            (r) in
            
            let _ = testList.append("1234")
            let _ = testList.removeFirst()
            let _ = testList.count
        }
        
        NSLog("\ntransaction result: \(String(describing: result))")
        XCTAssertNotNil(result)
    }
}
