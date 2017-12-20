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
            guard let result = maybeResult else {
                return ""
            }
            
            return String(describing: result)
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
}
