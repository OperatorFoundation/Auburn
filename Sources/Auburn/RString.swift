//
//  RString.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/3/17.
//

import Foundation
import RedShot

public final class RString: RBase, ExpressibleByStringLiteral, LosslessStringConvertible {
    public typealias StringLiteralType = String
    public var description: String {
        get {
            guard let r = Auburn.redis else {
                return ""
            }

            let maybeResult = try? r.get(key: key)
            guard let result = maybeResult as? String else {
                return ""
            }

            return result
        }
    }

    public init(_ stringLiteral: StringLiteralType) {
        super.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.set(key: key, value: stringLiteral)
    }

    public init(stringLiteral: StringLiteralType) {
        super.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.set(key: key, value: stringLiteral)
    }
    
    public override init() {
        super.init()
    }
    
    public override init(key: String) {
        super.init(key: key)
    }
}

extension RString: Equatable {
    public static func ==(lhs: RString, rhs: RString) -> Bool {
        let dest: RString = RString()
        
        guard let r = Auburn.redis else {
            return false
        }
        
        _ = try? r.sendCommand("bitop", values: ["XOR", dest.key, lhs.key, rhs.key])
        let maybeResult = try? r.sendCommand("bitcount", values: [dest.key])
        guard let result = maybeResult else {
            return false
        }
        let intResult = result as! Int
        
        return intResult == 0
    }
}
