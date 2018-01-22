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

    var count: Index
    {
        get {
            let r = Auburn.redis!
            let maybeResult = try? r.sendCommand("zcard", values: [self.key])
            guard let result = maybeResult else {
                return 0
            }

            return result as! Int
        }
    }

    public convenience init(arrayLiteral elements: LiteralType...)
    {
        self.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.sendCommand("del", values: [key])

        for value in elements {
            _ = try? r.sendCommand("zadd", values: [key, String(describing: 0), String(describing: value)])
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
            _ = try? r.sendCommand("zadd", values: [key, String(describing: value), String(describing: itemKey)])
        }
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

    // SetAlgebra

    // Score is ignored
    public func contains(_ member: Element) -> Bool {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return false
        }

        let (itemKey, _) = member

        let maybeResult = try? r.sendCommand("zrank", values: [key, String(describing: itemKey)])
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

        _ = try? r.sendCommand("zunionstore", values: [u.key, "2", self.key, other.key])

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

        let maybeResult = try? r.sendCommand("zadd", values: [self.key, String(describing: score), String(describing: itemKey)])
        guard let result = maybeResult else {
            return (false, newMember)
        }

        return (String(describing: result) == "1", newMember)
    }

    // Score is ignored
    public func remove(_ member: Element) -> Element? {
        guard let r = Auburn.redis else {
            return nil
        }

        let (itemKey, _) = member

        let maybeResult = try? r.sendCommand("zrem", values: [self.key, String(describing: itemKey)])
        guard let result = maybeResult else {
            return nil
        }

        return (itemKey, Float(String(describing: result))!)
    }

    public func update(with newMember: Element) -> Element? {
        guard let r = Auburn.redis else {
            return nil
        }

        let (itemKey, score) = newMember

        let maybeResult = try? r.sendCommand("zadd", values: [self.key, String(describing: score), String(describing: itemKey)])
        guard let result = maybeResult else {
            return nil
        }

        return (itemKey, Float(String(describing: result))!)
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
        print("ZRange: \(self.key), \(String(describing: position))")
        let maybeResult = try? r.sendCommand("zrange", values: [self.key, String(describing: position), String(describing: position)])
        
        guard let result = maybeResult as? [RedisType]
        else
        {
            return nil
        }
        
        let typeString = "\(LiteralType.self)"
        print("Subscript Result Count:\(result.count)")
        print("Requested position: \(position)")
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
                        return String(describing: result) as? LiteralType
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
}
