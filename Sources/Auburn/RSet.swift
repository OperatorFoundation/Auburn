//
//  RSet.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/2/17.
//

import Foundation
import RedShot
import Datable

public final class RSet<LiteralType: RedisType>: RBase, ExpressibleByArrayLiteral, Equatable, SetAlgebra, Sequence {
    public typealias Element = LiteralType
    public typealias Iterator = IndexingIterator<[LiteralType]>
    public typealias Index = Int

    let startIndex: Index = 0
    var endIndex: Index {
        get {
            return count
        }
    }

    public var count: Index {
        get {
            let r = Auburn.redis!
            let maybeResult = try? r.sendCommand("scard", values: [self.key])
            guard let result = maybeResult else {
                return 0
            }

            return result as! Int
        }
    }

    // ExpressibleByArrayLiteral
    public convenience required init(arrayLiteral elements: LiteralType...) {
        self.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.sendCommand("del", values: [self.key])

        for value in elements {
            _ = try?r.sadd(key: self.key, values: value)
        }
    }

    // Equatable
    public static func == (lhs: RSet<LiteralType>, rhs: RSet<LiteralType>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        return lhs.union(rhs).count == lhs.count
    }

    // SetAlgebra
    public func contains(_ member: LiteralType) -> Bool {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return false
        }

        let maybeResult = try? r.sendCommand("sismember", values: [key, member])
        guard let result = maybeResult as? Int else {
            return false
        }

        return result == 1
    }

    public func union(_ other: RSet<LiteralType>) -> RSet<LiteralType>
    {
        let u = RSet<LiteralType>()

        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return u
        }

        _ = try? r.sendCommand("sunionstore", values: [u.key, self.key, other.key])

        return u
    }

    public func intersection(_ other: RSet<LiteralType>) -> RSet<LiteralType> {
        let inter = RSet<LiteralType>()

        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return inter
        }

        _ = try? r.sendCommand("sinterstore", values: [inter.key, self.key, other.key])

        return inter
    }

    public func symmetricDifference(_ other: RSet<LiteralType>) -> RSet<LiteralType> {
        let result = RSet<LiteralType>()

        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return result
        }

        let diff1 = RSet<LiteralType>()
        let diff2 = RSet<LiteralType>()

        _ = try? r.sendCommand("sdiffstore", values: [diff1.key, self.key, other.key])
        _ = try? r.sendCommand("sdiffstore", values: [diff2.key, other.key, self.key])
        _ = try? r.sendCommand("sunionstore", values: [result.key, diff1.key, diff2.key])

        return result
    }

    public func insert(_ newMember: LiteralType) -> (inserted: Bool, memberAfterInsert: LiteralType) {
        guard let r = Auburn.redis else {
            return (false, newMember)
        }

        let maybeResult = try? r.sadd(key: self.key, values: newMember)
        guard let result = maybeResult as? Int else {
            return (false, newMember)
        }

        return (result == 1, newMember)
    }

    public func remove(_ member: LiteralType) -> LiteralType? {
        guard let r = Auburn.redis else {
            return nil
        }

        let maybeResult = try? r.sendCommand("srem", values: [self.key, member])
        guard let result = maybeResult as? Int else {
            return nil
        }

        if result == 1 {
            return member
        } else {
            return nil
        }
    }

    public func update(with newMember: LiteralType) -> LiteralType? {
        guard let r = Auburn.redis else {
            return nil
        }

        let maybeResult = try? r.sadd(key: self.key, values: newMember)
        guard let result = maybeResult as? Int else {
            return nil
        }

        if result == 1 {
            return newMember
        } else {
            return nil
        }
    }

    public func formUnion(_ other: RSet<LiteralType>) {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return
        }

        _ = try? r.sendCommand("sunionstore", values: [self.key, self.key, other.key])
    }

    public func formIntersection(_ other: RSet<LiteralType>) {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return
        }

        _ = try? r.sendCommand("sinterstore", values: [self.key, self.key, other.key])
    }

    public func formSymmetricDifference(_ other: RSet<LiteralType>) {
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return
        }

        let diff1 = RSet<LiteralType>()
        let diff2 = RSet<LiteralType>()

        _ = try? r.sendCommand("sdiffstore", values: [diff1.key, self.key, other.key])
        _ = try? r.sendCommand("sdiffstore", values: [diff2.key, other.key, self.key])
        _ = try? r.sendCommand("sunionstore", values: [self.key, diff1.key, diff2.key])
    }

    // Sequence
    public subscript(position: Int) -> LiteralType?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.smembers(key: self.key)
        
        guard let result = maybeResult as? [RedisType]
        else
        {
            return nil
        }

        let typeString = "\(LiteralType.self)"

        switch typeString
        {
            case "String":
                switch result[position]
                {
                    case let dataResult as Data:
                        return dataResult.string as? LiteralType
                    case let stringResult as String:
                        return stringResult as? LiteralType
                    default:
                        return result as? LiteralType
                }
            case "Data":
                switch result[position]
                {
                    case let dataResult as Data:
                        return dataResult as? LiteralType
                    case let stringResult as String:
                        return stringResult.data as? LiteralType
                    default:
                        return nil
                }
            case "Int":
                switch result[position]
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
                switch result[position]
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
                switch result[position]
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
    
//    public subscript(position: Int) -> LiteralType?
//    {
//        let r = Auburn.redis!
//        let maybeResult = try? r.smbembers(key: self.key)
//
//        print("\n\(maybeResult!)")
//
//        guard let result = maybeResult as? [LiteralType]
//        else
//        {
//            return nil
//        }
//
//        return result[position] as? LiteralType
//    }

    public func index(after i: Index) -> Index {
        return i + 1
    }

    // This is expensive because sets are unordered, so iteration requires fetching the whole set to fix an ordering.
    // The intention of providing iteration is mainly for testing purposes, using small sets.
    // You should probably not use this functionality in production as it will not be performant on large sets.
    public func makeIterator() -> IndexingIterator<[LiteralType]> {
        let r = Auburn.redis!
        let maybeResult = try? r.smembers(key: self.key)
        let result = maybeResult! as! [LiteralType]

        return result.makeIterator()
    }
}
