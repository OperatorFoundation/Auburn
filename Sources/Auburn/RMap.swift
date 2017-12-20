//
//  RMap.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/1/17.
//

import Foundation
import RedShot

public class RMap<K: LosslessStringConvertible, V: LosslessStringConvertible>: RBase, ExpressibleByDictionaryLiteral {
    public typealias Key = K
    public typealias Value = V
    
    public required convenience init(dictionaryLiteral elements: (K, V)...) {
        self.init()
        
        guard let r = Auburn.redis else {
            return
        }
        
        _ = try? r.sendCommand("del", values: [key])
        
        for (itemKey, value) in elements {
            _ = try? r.hset(key: key, field: String(describing: itemKey), value: String(describing: value))
        }
    }
        
    public subscript(key: K) -> V {
        let r = Auburn.redis!
        let maybeResult = try? r.sendCommand("hget", values: [self.key, String(describing: key)])
        let result = maybeResult!
        
        let typeString="\(V.self)"
        
        switch typeString {
        case "String":
            return String(describing: result) as! V
        case "Int":
            return Int(String(describing: result)) as! V
        case "Float":
            return Float(String(describing: result)) as! V
        case "Double":
            return Double(String(describing: result)) as! V
        default:
            return "" as! V
        }
    }
}
