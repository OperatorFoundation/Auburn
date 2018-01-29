//
//  RMap.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/1/17.
//

import Foundation
import RedShot
import Datable

public class RMap<K: Datable, V: Datable>: RBase, ExpressibleByDictionaryLiteral
{
    public typealias Key = K
    public typealias Value = V

    public required convenience init(dictionaryLiteral elements: (K, V)...)
    {
        self.init()

        guard let r = Auburn.redis else
        {
            return
        }

        _ = try? r.sendCommand("del", values: [key])

        for (itemKey, value) in elements
        {
            _ = try? r.hset(key: key, field: String(describing: itemKey), value: value)
        }
    }

    public subscript(key: K) -> V?
    {
        get
        {
            let r = Auburn.redis!
            let maybeResult = try? r.hget(key: self.key, field: key)
            guard let result = maybeResult
                else
            {
                return nil
            }
            
            if "\(type(of: result))" == "NSNull"
            {
                return nil
            }
            
            let typeString = "\(V.self)"
            
            switch typeString
            {
            case "String":
                switch result
                {
                case let dataResult as Data:
                    return dataResult.string as? V
                case let stringResult as String:
                    return stringResult as? V
                case let intResult as Int:
                    return String(intResult) as? V
                default:
                    return String(describing: result) as? V
                }
            case "Int":
                switch result
                {
                case let dataResult as Data:
                    let stringValue = dataResult.string
                    return Int(stringValue) as? V
                case let stringResult as String:
                    return Int(stringResult) as? V
                case let intResult as Int:
                    return intResult as? V
                default:
                    return nil
                }
            case "Float":
                switch result
                {
                case let dataResult as Data:
                    let dataToFLoat = Float(bitPattern: UInt32(bigEndian: dataResult.withUnsafeBytes { $0.pointee } ))
                    return dataToFLoat as? V
                case let stringResult as String:
                    return Float(stringResult) as? V
                case let intResult as Int:
                    return Float(intResult) as? V
                default:
                    return nil
                }
            case "Double":
                switch result
                {
                case let dataResult as Data:
                    return Double(dataResult.string) as? V
                case let stringResult as String:
                    return Double(stringResult) as? V
                case let intResult as Int:
                    return Double(intResult) as? V
                default:
                    return nil
                }
            case "Data":
                switch result
                {
                    case let dataResult as Data:
                        return dataResult as? V
                    case let stringResult as String:
                        return stringResult.data as? V
                    case let intResult as Int:
                        return intResult.data as? V
                    default:
                        return nil
                }
            default:
                return nil
            }
        }
        set(newValue)
        {
            let r = Auburn.redis!
            guard let fieldValue = newValue
            else
            {
                return
            }
            _ = try? r.hset(key: self.key, field: String(describing: key), value: fieldValue)
        }
    }
    
    public func increment(field fieldKey: K) -> V?
    {
        guard let redis = Auburn.redis
            else
        {
            return nil
        }
        
        let hincrbyResult = try? redis.hincrby(hashKey: self.key, increment: 1, fieldKey: fieldKey)
        guard let result = hincrbyResult as? Datable
            else
        {
            return nil
        }
        
        if "\(type(of: result))" == "NSNull"
        {
            return nil
        }
        
        let resultAsInt:Int?
        
        switch result
        {
        case let dataResult as Data:
            let stringFromData = dataResult.string
            resultAsInt = Int(stringFromData)
        case let stringResult as String:
            resultAsInt = Int(stringResult)
        case let intResult as Int:
            resultAsInt = intResult
        default:
            return nil
        }
        
        guard let actualInt = resultAsInt
        else
        {
            return nil
        }
        
        let typeString = "\(V.self)"
        switch typeString
        {
        case "Int":
            return actualInt as! V
        case "String":
            return String(actualInt) as! V
        case "Data":
            return actualInt.data as! V
        case "Float":
            return Float(actualInt) as! V
        case "Double":
            return Double(actualInt) as! V
       default:
            return nil
        }
    }
    
}
