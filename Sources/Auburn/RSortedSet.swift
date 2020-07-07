//
//  RSortedSet.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/2/17.
//

import Foundation
import RedShot
import Datable

public final class RSortedSet<LiteralType: RedisType>: RBase, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, Equatable, SetAlgebra
{
    public typealias Element = (LiteralType, Float)
    public typealias Index = Int

    public var count: Index
    {
        get
        {
            let r = Auburn.redis!
            let maybeResult = try? r.sendCommand("zcard", values: [self.key])
            guard let result = maybeResult
            else
            {
                return 0
            }

            if "\(type(of: result))" == "NSNull"
            {
                return 0
            }
            
            switch result
            {
            case let dataResult as Data:
                let stringResult = dataResult.string
                return Int(stringResult) ?? 0
            case let stringResult as String:
                return Int(stringResult) ?? 0
            case let intResult as Int:
                return intResult
            default:
                return 0
            }
        }
    }
    
    public var first: Element?
    {
        guard let r = Auburn.redis
            else
        {
            return nil
        }
        
        let maybeResults = try? r.zrange(setKey: self.key, minIndex: 0, maxIndex: 0, withScores: true)
        guard let results = maybeResults
            else
        {
            return nil
        }
        
        if "\(type(of: results))" == "NSNull"
        {
            return nil
        }
        
        return processZrange(results: results)
    }

    public var last: Element?
    {
        guard let r = Auburn.redis
            else
        {
            return nil
        }
        
        let maybeResults = try? r.zrevrange(setKey: self.key, minIndex: 0, maxIndex: 0, withScores: true)
        
        guard let results = maybeResults
            else
        {
            return nil
        }
        
        if "\(type(of: results))" == "NSNull"
        {
            return nil
        }
        
        return processZrange(results: results)
    }
    
    public convenience init(arrayLiteral elements: LiteralType...)
    {
        self.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.sendCommand("del", values: [key])

        for value in elements {
            _ = try? r.sendCommand("zadd", values: [key, 0, value])
        }
    }

    public required convenience init(dictionaryLiteral elements: (LiteralType, Float)...)
    {
        self.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.sendCommand("del", values: [key])

        for (itemKey, value) in elements {
            _ = try? r.sendCommand("zadd", values: [key, value, itemKey])
        }
    }
    
    public convenience init(unionOf firstSetKey: String, scoresMultipliedBy firstWeight: Double, secondSetKey: String, scoresMultipliedBy secondWeight: Double, newSetKey key: String)
    {
        self.init(key: key)
        self.delete()
        
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return
        }
        _ = try? r.zunionstore(newSetKey: key, firstSetKey: firstSetKey, secondSetKey: secondSetKey, firstWeight: firstWeight, secondWeight: secondWeight)
    }

    public static func ==(lhs: RSortedSet<LiteralType>, rhs: RSortedSet<LiteralType>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        return lhs.intersection(rhs).count == lhs.count
    }

    public subscript(key: LiteralType) -> Float?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.zscore(setKey: self.key, fieldKey: key)
        guard let result = maybeResult
        else
        {
            return nil
        }
        
        if "\(type(of: result))" == "NSNull"
        {
            return nil
        }
        
        switch result
        {
            case let dataResult as Data:
                let stringFromData = dataResult.string
                return Float(stringFromData)
            case let stringResult as String:
                return Float(stringResult)
            case let intResult as Int:
                return Float(intResult)
            default:
                return nil
        }
    }
    
    /// ZSCORE Returns the score of member in the sorted set at key.
    /// If member does not exist in the sorted set, or key does not exist, nil is returned.
    ///
    /// - Parameters:
    ///   - element: The member of the sorted set to return the score for.
    /// - Returns:  Optional Float, The score of member.
    public func getScore(for element: LiteralType) -> Float?
    {
        guard let r = Auburn.redis
            else
        {
            return nil
        }
        
        let maybeResult = try? r.zscore(setKey: self.key, fieldKey: element)
        
        guard let result = maybeResult as? Data
        else
       {
           return nil
       }
        
        let stringFromData = result.string
        return Float(stringFromData)
    }
    
    /// Returns all the element keys in the sorted set with a score between min and max (including elements with score equal to min or max). The elements are considered to be ordered from low to high scores.
    public func getElements(withMinScore minScore: Double, andMaxScore maxScore: Double) -> [LiteralType]?
    {
        guard let r = Auburn.redis
            else { return nil }
        
        let maybeResults = try? r.zrangebyscore(setKey: self.key, minScore: minScore, maxScore: maxScore)
        
        guard let results = maybeResults as? [RedisType], results.isEmpty == false
            else
        {
            print("\nNil result from zrangebyscore command.\n")
            return nil
        }
        
        if "\(type(of: results))" == "NSNull"
        {
            print("\nNil result from zrangebyscore command.\n")
            return nil
        }
        
        if let convertedArray = convert(resultArray: results)
        {
            return convertedArray
        }
        else
        {
            return nil
        }
    }

    // SetAlgebra

    // Score is ignored
    public func contains(_ member: Element) -> Bool {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return false
        }

        let (itemKey, _) = member

        let maybeResult = try? r.sendCommand("zrank", values: [key, itemKey])
        guard let result = maybeResult else {
            return false
        }

        return type(of: result) != NSNull.self
    }

    public func union(_ other: RSortedSet<LiteralType>) -> RSortedSet<LiteralType> {
        let u = RSortedSet<LiteralType>()

        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return u
        }

        _ = try? r.zunionstore(newSetKey: u.key, firstSetKey: self.key, secondSetKey: other.key, firstWeight: 1, secondWeight: 1)

        return u
    }
    
    public func weightedUnion(_ other: RSortedSet<LiteralType>, weight: Double, otherWeight: Double) -> RSortedSet<LiteralType>
    {
        let u = RSortedSet<LiteralType>()
        
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return u
        }
        
        _ = try? r.zunionstore(newSetKey: u.key, firstSetKey: self.key, secondSetKey: other.key, firstWeight: weight, secondWeight: otherWeight)
        
        return u
    }

    public func intersection(_ other: RSortedSet<LiteralType>) -> RSortedSet<LiteralType> {
        let inter = RSortedSet<LiteralType>()
        self.persistent=true
        inter.persistent=true
        other.persistent=true

        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return inter
        }

        _ = try? r.sendCommand("zinterstore", values: [inter.key, "2", self.key, other.key])

        return inter
    }

    // This is expensive as Redis does not have a zdiffstore command.
    // This should only be using in testing with small keys.
    // Do not use this in production as it will not be performant with large datasets.
    public func symmetricDifference(_ other: RSortedSet<LiteralType>) -> RSortedSet<LiteralType>
    {
        let inter = RSortedSet<LiteralType>()
        let u = RSortedSet<LiteralType>()

        guard let r = Auburn.redis else
        {
            NSLog("No redis connection")
            return u
        }

        _ = try? r.sendCommand("zinterstore", values: [inter.key, "2", self.key, other.key])
        _ = try? r.sendCommand("zunionstore", values: [u.key, "2", self.key, other.key])

        let maybeResult = try? r.sendCommand("zrange", values: [inter.key, "0", "-1"])
        guard let results = maybeResult as? [RedisType], results.isEmpty == false
        else
        {
            print("\nNil result from zrange command.\n")
            return RSortedSet<LiteralType>()
        }
        
        if "\(type(of: results))" == "NSNull"
        {
            print("\nNil result from zrange command.\n")
            return RSortedSet<LiteralType>()
        }
        

        for result in results
        {
            switch result
            {
            case let dataResult as Data:
                _ = try? r.sendCommand("zrem", values: [u.key, dataResult])
            case let stringResult as String:
                _ = try? r.sendCommand("zrem", values: [u.key, stringResult])
            case let intResult as Int:
                _ = try? r.sendCommand("zrem", values: [u.key, intResult])
            default:
                return RSortedSet<LiteralType>()
                
            }
        }

        return u
    }

    public func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        guard let r = Auburn.redis else {
            return (false, newMember)
        }

        let (itemKey, score) = newMember

        let maybeResult = try? r.sendCommand("zadd", values: [self.key, score, itemKey])
        guard let result = maybeResult as? Int else {
            return (false, newMember)
        }

        return (result == 1, newMember)
    }

    // Score is ignored
    public func remove(_ member: Element) -> Element? {
        guard let r = Auburn.redis else {
            return nil
        }

        let (itemKey, _) = member

        let maybeResult = try? r.sendCommand("zrem", values: [self.key, itemKey])
        guard let result = maybeResult as? Float else {
            return nil
        }

        return (itemKey, result)
    }
    
    public func incrementScore(ofField fieldKey: LiteralType, byIncrement increment: Double) -> Double?
    {
        guard let redis = Auburn.redis
        else
        {
            return nil
        }
        
        let result = try? redis.zincrby(setKey: self.key, increment: increment, fieldKey: fieldKey)
        
        if "\(type(of: result))" == "NSNull"
        {
            return nil
        }
        
        switch result
        {
            case let dataResult as Data:
                let stringFromData = dataResult.string
                return Double(stringFromData)
            case let stringResult as String:
                return Double(stringResult)
            case let intResult as Int:
                return Double(intResult)
            default:
                return nil
        }
    }

    public func update(with newMember: Element) -> Element? {
        guard let r = Auburn.redis else {
            return nil
        }

        let (itemKey, score) = newMember

        let maybeResult = try? r.sendCommand("zadd", values: [self.key, score, itemKey])
        guard let result = maybeResult as? Float else {
            return nil
        }

        return (itemKey, result)
    }

    public func formUnion(_ other: RSortedSet<LiteralType>) {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return
        }

        _ = try? r.sendCommand("zunionstore", values: [self.key, "2", self.key, other.key])
    }

    public func formIntersection(_ other: RSortedSet<LiteralType>) {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return
        }

        _ = try? r.sendCommand("zinterstore", values: [self.key, "2", self.key, other.key])
    }

    // This is expensive as Redis does not have a zdiffstore command.
    // This should only be using in testing with small keys.
    // Do not use this in production as it will not be performant with large datasets.
    public func formSymmetricDifference(_ other: RSortedSet<LiteralType>)
    {
        let inter = RSortedSet<LiteralType>()

        guard let r = Auburn.redis else
        {
            NSLog("No redis connection")
            return
        }

        _ = try? r.sendCommand("zinterstore", values: [inter.key, "2", self.key, other.key])
        _ = try? r.sendCommand("zunionstore", values: [self.key, "2", self.key, other.key])

        let maybeResult = try? r.sendCommand("zrange", values: [inter.key, "0", "-1"])
        guard let results = maybeResult as? [RedisType], results.isEmpty == false
            else
        {
            print("\nNil result from zrange command.\n")
            return
        }
        
        if "\(type(of: results))" == "NSNull"
        {
            print("\nNil result from zrange command.\n")
            return
        }

        for result in results
        {
            switch result
            {
                case let dataResult as Data:
                    _ = try? r.sendCommand("zrem", values: [self.key, dataResult])
                case let stringResult as String:
                    _ = try? r.sendCommand("zrem", values: [self.key, stringResult])
                case let intResult as Int:
                    _ = try? r.sendCommand("zrem", values: [self.key, intResult])
                default:
                    return
            }
        }
    }

    // Sequence
    public subscript(position: Int) -> LiteralType?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("zrange", values: [self.key, position, position])
        
        guard let result = maybeResult as? [RedisType]
        else
        {
            return nil
        }
        
        return convert(result: result[0])
    }

    public func index(after i: Index) -> Index {
        return i + 1
    }

    // This is expensive because sets are unordered, so iteration requires fetching the whole set to fix an ordering.
    // The intention of providing iteration is mainly for testing purposes, using small sets.
    // You should probably not use this functionality in production as it will not be performant on large sets.
    public func makeIterator() -> IndexingIterator<[LiteralType]> {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("zrange", values: [self.key, "0", "-1"])
        let result = maybeResult! as! [LiteralType]

        return result.makeIterator()
    }
    
    /**
     Removes and returns up to count members with the lowest scores in the sorted set.
     
     - Parameters:
        - numberToRemove: number of elements to remove from the sorted set and return to the requestor. When left unspecified, the default value for count is 1. Specifying a count value that is higher than the sorted set's cardinality will not produce an error.
     - Returns: An array of tuples containing popped elements and their scores sorted lowest to highest. When returning multiple elements, the one with the lowest score will be the first, followed by the elements with greater scores.
     */
    public func removeLowest(numberToRemove count: Int?) -> [(value: LiteralType, score: Float)]?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.zpopmin(key: self.key, count: count)

        guard let result = maybeResult as? [RedisType]
            else { return nil }
        
        var returnArray = [(value: LiteralType, score: Float)]()
        
        for index in stride(from: 0, to: result.count, by: 2)
        {
            if let value = convert(result: result[index])
            {
                let scoreResult = result[index + 1]
                let score: Float?
                
                switch scoreResult
                {
                case let dataResult as Data:
                    score = Float(dataResult.string)
                case let stringResult as String:
                    score = Float(stringResult)
                case let floatResult as Float:
                    score = floatResult
                default:
                    score = nil
                }
                
                if score != nil
                {
                    returnArray.append((value: value, score: Float(score!)))
                }
            }
        }
        
        if returnArray.isEmpty
        { return nil }
        else
        { return returnArray }
    }
    
    /**
     Removes and returns up to count members with the highest scores in the sorted set.
     
     - Parameters:
        - numberToRemove: number of elements to remove from the sorted set and return to the requestor. When left unspecified, the default value for count is 1. Specifying a count value that is higher than the sorted set's cardinality will not produce an error.
     - Returns: An array of tuples containing popped elements and their scores sorted highest to lowest. When returning multiple elements, the one with the highest score will be the first, followed by the elements with lower scores.
     */
    public func removeHighest(numberToRemove count: Int?) -> [(value: LiteralType, score: Float)]?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.zpopmax(key: self.key, count: count)
        
        guard let result = maybeResult as? [RedisType]
            else { return nil }
        
        var returnArray = [(value: LiteralType, score: Float)]()
        
        for index in stride(from: 0, to: result.count, by: 2)
        {
            if let value = convert(result: result[index])
            {
                let scoreResult = result[index + 1]
                let score: Float?
                
                switch scoreResult
                {
                case let dataResult as Data:
                    score = Float(dataResult.string)
                case let stringResult as String:
                    score = Float(stringResult)
                case let floatResult as Float:
                    score = floatResult
                default:
                    score = nil
                }
                
                if score != nil
                {
                    returnArray.append((value: value, score: Float(score!)))
                }
            }
        }
        
        if returnArray.isEmpty
        { return nil }
        else
        { return returnArray }
    }
    
    public func addSubsequences(offsetPrefix: String, sequence: Data) -> Int?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("subsequences.add", values: [self.key, offsetPrefix, sequence])
        
        guard let result = maybeResult
            else
        {
            return nil
        }
        
        switch result
        {
        case let intResult as Int:
            return intResult
        default:
            return nil
        }
    }
    
    public func getLongestSequence(withScore score: Double) -> LiteralType?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("subsequences.rangeByLength", values: [self.key, score])
        
        guard let result = maybeResult
            else
        {
            return nil
        }
        
        guard let dataResult = result as? Data
        else
        {
            return nil
        }
        
        let typeString = "\(LiteralType.self)"
        switch typeString
        {
            case "String":
                return dataResult.string as? LiteralType
            case "Data":
                return dataResult as? LiteralType
            case "Int":
                return Int(dataResult.string) as? LiteralType
            case "Float":
                return Float(dataResult.string) as? LiteralType
            case "Double":
                return Double(dataResult.string) as? LiteralType
            default:
                return nil
        }
    }
    
    func processZrange(results: RedisType) -> Element?
    {
        switch results {
        case let resultsArray as Array<RedisType>:
            if resultsArray.count < 2{
                return nil
            }
            
            let item = resultsArray[0]
            let score = resultsArray[1]
            
            switch score
            {
            case let dataScore as Data:
                let stringScore = dataScore.string
                let floatScore = Float(stringScore)
                
                switch item
                {
                case let dataItem as Data:
                    let returnType = "\(LiteralType.self)"
                    switch returnType
                    {
                    case "Int":
                        let maybeIntItem = Int(dataItem.string)
                        guard let intItem = maybeIntItem
                            else { return nil }
                        return ((intItem, floatScore) as! Element)
                        
                    case "Double":
                        let maybeDoubleItem = Double(dataItem.string)
                        guard let doubleItem = maybeDoubleItem
                            else { return nil }
                        return ((doubleItem, floatScore) as! Element)
                        
                    case "String":
                        let stringItem = dataItem.string
                        return ((stringItem, floatScore) as! Element)
                        
                    case "Data":
                        return ((dataItem, floatScore) as! Element)
                        
                    default:
                        return nil
                    }
                default:
                    return nil
                }
                
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func convert(resultArray: [RedisType]) -> [LiteralType]?
    {
        if resultArray.isEmpty
        {
            return nil
        }
        else
        {
            var convertedObjects = [LiteralType]()
            for result in resultArray
            {
                if let converted = convert(result: result)
                {
                    convertedObjects.append(converted)
                }
            }
            
            if convertedObjects.isEmpty
            {
                return nil
            }
            else
            {
                return convertedObjects
            }
        }
    }
    
    func convert(result: RedisType) -> LiteralType?
    {
        let typeString = "\(LiteralType.self)"
        switch typeString
        {
        case "String":
            switch result
            {
            case let dataResult as Data:
                return dataResult.string as? LiteralType
            case let stringResult as String:
                return stringResult as? LiteralType
            default:
                return result as? LiteralType
            }
        case "Data":
            switch result
            {
            case let dataResult as Data:
                return dataResult as? LiteralType
            case let stringResult as String:
                return stringResult.data as? LiteralType
            default:
                return nil
            }
        case "Int":
            switch result
            {
            case let dataResult as Data:
                return Int(dataResult.string) as? LiteralType
            case let stringResult as String:
                return Int(stringResult) as? LiteralType
            case let intResult as Int:
                return intResult as? LiteralType
            default:
                return nil
            }
        case "Float":
            switch result
            {
            case let dataResult as Data:
                return Float(dataResult.string) as? LiteralType
            case let stringResult as String:
                return Float(stringResult) as? LiteralType
            case let floatResult as Float:
                return floatResult as? LiteralType
            default:
                return nil
            }
        case "Double":
            switch result
            {
            case let dataResult as Data:
                return Double(dataResult.string) as? LiteralType
            case let stringResult as String:
                return Double(stringResult) as? LiteralType
            case let doubleResult as Double:
                return doubleResult as? LiteralType
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}
