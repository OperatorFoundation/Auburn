//
//  RSet.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/2/17.
//

import Foundation
import RedShot

public final class RSet<LiteralType>: RBase, ExpressibleByArrayLiteral, Equatable, SetAlgebra, Sequence {
    public typealias Element = LiteralType
    public typealias Iterator = IndexingIterator<[LiteralType]>
    public typealias Index = Int
    
    let startIndex: Index = 0
    var endIndex: Index {
        get {
            return count
        }
    }

    var count: Index {
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
            _ = try? r.sendCommand("sadd", values: [self.key, String(describing: value)])
        }
    }
    
    // Equatable
    public static func ==(lhs: RSet<LiteralType>, rhs: RSet<LiteralType>) -> Bool {
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

        let maybeResult = try? r.sendCommand("sismember", values: [key, String(describing: member)])
        guard let result = maybeResult else {
            return false
        }
        
        return String(describing: result) == "1"
    }
    
    public func union(_ other: RSet<LiteralType>) -> RSet<LiteralType> {
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
        
        let maybeResult = try? r.sendCommand("sadd", values: [self.key, String(describing: newMember)])
        guard let result = maybeResult else {
            return (false, newMember)
        }
        
        return (String(describing: result) == "1", newMember)
    }
    
    public func remove(_ member: LiteralType) -> LiteralType? {
        guard let r = Auburn.redis else {
            return nil
        }
        
        let maybeResult = try? r.sendCommand("srem", values: [self.key, String(describing: member)])
        guard let result = maybeResult else {
            return nil
        }

        if String(describing: result) == "1" {
            return member
        } else {
            return nil
        }
    }
    
    public func update(with newMember: LiteralType) -> LiteralType? {
        guard let r = Auburn.redis else {
            return nil
        }
        
        let maybeResult = try? r.sendCommand("sadd", values: [self.key, String(describing: newMember)])
        guard let result = maybeResult else {
            return nil
        }
        
        if String(describing: result) == "1" {
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
    public subscript(position: Int) -> LiteralType {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("smembers", values: [self.key])
        let result = maybeResult! as! [LiteralType]
        
        return String(describing: result[position]) as! LiteralType
    }
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    // This is expensive because sets are unordered, so iteration requires fetching the whole set to fix an ordering.
    // The intention of providing iteration is mainly for testing purposes, using small sets.
    // You should probably not use this functionality in production as it will not be performant on large sets.
    public func makeIterator() -> IndexingIterator<[LiteralType]> {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("smembers", values: [self.key])
        let result = maybeResult! as! [LiteralType]
        
        return result.makeIterator()
    }
}
