//
//  RList.swift
//  Auburn
//
//  Created by Brandon Wiley on 11/29/17.
//

import Foundation
import RedShot

public struct RListSubSequence<LiteralType>: Sequence {
    public typealias Element = LiteralType
    public typealias Iterator = RListIterator<LiteralType>
    public typealias Index = Int

    var parent: RList<LiteralType>
    let startIndex: Index
    let endIndex: Index

    public func makeIterator() -> RListIterator<LiteralType> {
        if Auburn.redis == nil {
            return RListIterator<LiteralType>()
        } else {
            return RListIterator<LiteralType>(parent: parent, startIndex: startIndex, endIndex: endIndex)
        }
    }

    public subscript(position: Index) -> LiteralType? {
        return parent[position + startIndex]
    }

    public func index(after i: Index) -> Index {
        return i + 1
    }
}

public struct RListIterator<LiteralType>: IteratorProtocol {
    public typealias Element = LiteralType
    public typealias Index = Int

    var parent: RList<LiteralType>?
    let startIndex: Index
    let endIndex: Index

    public init() {
        parent = nil
        startIndex = 0
        endIndex = -1
    }

    public init(parent: RList<LiteralType>, startIndex: Index, endIndex: Index) {
        self.parent=parent
        self.startIndex=startIndex
        self.endIndex=endIndex
    }

    public func next() -> LiteralType? {
        guard let realParent = parent else {
            return nil
        }

        guard let r = Auburn.redis else {
            return nil
        }

        let maybeResult = try? r.get(key: realParent.key)
        guard let result = maybeResult else {
            return nil
        }

        switch result {
        case is String:
            return result as? LiteralType
        default:
            return nil
        }
    }
}

public final class RList<LiteralType>: RBase, ExpressibleByArrayLiteral, Sequence {
    public typealias ArrayLiteralElement = LiteralType
    public typealias Index = Int
    public typealias Element = LiteralType
    public typealias SubSequence = RListSubSequence<LiteralType>
//    typealias SubSequence<LiteralType> = Slice<RList<LiteralType>> where SubSequence<LiteralType>.Index == Index, SubSequence<LiteralType>.IndexDistance == IndexDistance
    public typealias Iterator = RListIterator<LiteralType>

    public var startIndex: RList<LiteralType>.Index = 0
    public var endIndex: RList<LiteralType>.Index = -1

    public var count: Index {
        get {
            let r = Auburn.redis!
            let maybeResult = try? r.sendCommand("llen", values: [self.key])
            guard let result = maybeResult else {
                return 0
            }

            return result as! Int
        }
    }

    public convenience init(arrayLiteral elements: LiteralType...) {
        self.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.sendCommand("del", values: [key])

        for value in elements {
            _ = try? r.sendCommand("rpush", values: [key, String(describing: value)])
        }
    }

    public func dropFirst(_ n: Int) -> RListSubSequence<LiteralType> {
        return RListSubSequence(parent: self, startIndex: n, endIndex: -1)
    }

    public func dropLast(_ n: Int) -> RListSubSequence<LiteralType> {
        return RListSubSequence(parent: self, startIndex: 0, endIndex: -n)
    }

    // FIXME - punting on this since I'm not sure how to implement it for real
    public func drop(while predicate: (LiteralType) throws -> Bool) rethrows -> RListSubSequence<LiteralType> {
        return RListSubSequence<LiteralType>(parent: self, startIndex: -1, endIndex: -1)
    }

    // FIXME - punting on this since I'm not sure how to implement it for real
    public func prefix(while predicate: (LiteralType) throws -> Bool) rethrows -> RListSubSequence<LiteralType> {
        return RListSubSequence<LiteralType>(parent: self, startIndex: -1, endIndex: -1)
    }

    public func prefix(_ maxLength: Int) -> RListSubSequence<LiteralType> {
        return RListSubSequence<LiteralType>(parent: self, startIndex: 0, endIndex: maxLength)
    }

    public func suffix(_ maxLength: Int) -> RListSubSequence<LiteralType> {
        return RListSubSequence<LiteralType>(parent: self, startIndex: -maxLength, endIndex: -1)
    }

    // FIXME - punting on this since I'm not sure how to implement it for real
    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (LiteralType) throws -> Bool) rethrows -> [RListSubSequence<LiteralType>] {
        return []
    }
    
    public func removeFirst() -> LiteralType?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.lpop(key: key)
        
        guard let result = maybeResult
        else
        {
            return nil
        }
        
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
                        return String(describing: result) as? LiteralType
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
                    case let floatResult as Float:
                        return floatResult as? LiteralType
                    default:
                        return nil
                }
            default:
                return nil
        }
    }

    public subscript(position: Index) -> LiteralType?
    {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("lindex", values: [key, String(position)])
        guard let result = maybeResult
        else
        {
            return nil
        }

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
                        return String(describing: result) as? LiteralType
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
                    case let floatResult as Float:
                        return floatResult as? LiteralType
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

    public func makeIterator() -> RListIterator<LiteralType> {
        return RListIterator<LiteralType>(parent: self, startIndex: startIndex, endIndex: endIndex)
    }
}

extension RList/*: *RangeReplaceableCollection*/ {
    public func append(_ newElement: RList.Element) {
        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.sendCommand("rpush", values: [key, String(describing: newElement)])
    }
}
