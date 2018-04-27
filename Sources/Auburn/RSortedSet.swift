//
//  RSortedSet.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/2/17.
//

import Foundation
import RedShot
import Datable

public final class RSortedSet<LiteralType: Datable>: RBase, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, Equatable, SetAlgebra
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
        let maybeResult = try? r.sendCommand("zscore", values: [self.key, key])
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
    
    /// Returns all the element keys in the sorted set with a score between min and max (including elements with score equal to min or max). The elements are considered to be ordered from low to high scores.
    public func getElements(withMinScore minScore: Int, andMaxScore maxScore: Int) -> [LiteralType]?
    {
        guard let r = Auburn.redis
            else
        {
            return nil
        }
        
        let maybeResults = try? r.zrangebyscore(setKey: self.key, minScore: minScore, maxScore: maxScore)
        
        guard let results = maybeResults as? [Datable], results.isEmpty == false
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
        let typeString = "\(LiteralType.self)"
        var resultsArray = [LiteralType]()
        for eachElement in results
        {
            
            switch typeString
            {
            case "String":
                switch eachElement
                {
                case let dataResult as Data:
                    if let newResult = dataResult.string as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let stringResult as String:
                    if let newResult = stringResult as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                default:
                    continue
                }
            case "Data":
                switch eachElement
                {
                case let dataResult as Data:
                    if let newResult = dataResult as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let stringResult as String:
                    if let newResult = stringResult.data as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                default:
                    continue
                }
            case "Int":
                switch eachElement
                {
                case let dataResult as Data:
                    if let newResult = Int(dataResult.string) as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let stringResult as String:
                    if let newResult = Int(stringResult) as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let intResult as Int:
                    if let newResult = intResult as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                default:
                    continue
                }
            case "Float":
                switch eachElement
                {
                case let dataResult as Data:
                    if let newResult = Float(dataResult.string) as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let stringResult as String:
                    if let newResult = Float(stringResult) as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let floatResult as Float:
                    if let newResult = floatResult as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                default:
                    continue
                }
            case "Double":
                switch eachElement
                {
                case let dataResult as Data:
                    if let newResult = Double(dataResult.string) as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let stringResult as String:
                    if let newResult = Double(stringResult) as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                case let doubleResult as Double:
                    if let newResult = doubleResult as? LiteralType
                    {
                        resultsArray.append(newResult)
                    }
                default:
                    continue
                }
            default:
                continue
            }
        }
        
        if resultsArray.isEmpty
        {
            return nil
        }
    
        return resultsArray
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
        
        let zincrbyResult = try? redis.zincrby(setKey: self.key, increment: increment, fieldKey: fieldKey)
        guard let result = zincrbyResult as? Datable
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
        
        let typeString = "\(LiteralType.self)"
        switch typeString
        {
            case "String":
                switch result[0]
                {
                    case let dataResult as Data:
                        return dataResult.string as? LiteralType
                    case let stringResult as String:
                        return stringResult as? LiteralType
                    default:
                        return result as? LiteralType
                }
            case "Data":
                switch result[0]
                {
                    case let dataResult as Data:
                        return dataResult as? LiteralType
                    case let stringResult as String:
                        return stringResult.data as? LiteralType
                    default:
                        return nil
                }
            case "Int":
                switch result[0]
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
                switch result[0]
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
                switch result[0]
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
    
    public func addSubsequences(offsetPrefix: String, sequence: Data) -> Int? {
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
    
    func processZrange(results: RedisType) -> Element?
    {
        switch results {
        case let resultsArray as Array<RedisType>:
            if resultsArray.count < 2{
                return nil
            }
            
            let item = resultsArray[0]
            let score = resultsArray[1]
            
            switch score {
            case let dataScore as Data:
                let stringScore = dataScore.string
                let floatScore = Float(stringScore)
                
                switch item {
                case let dataItem as Data:
                    
                    let returnType = "\(LiteralType.self)"
                    switch returnType {
                    case "Int":
                        let stringItem = dataItem.string
                        let maybeIntItem = Int(stringItem)
                        guard let intItem = maybeIntItem
                            else {
                                return nil
                        }
                        return ((intItem, floatScore) as! Element)
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
    
}
