//
//  RMap.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/1/17.
//

import Foundation
import RedShot
import Datable

public class RMap<K: RedisType, V: RedisType>: RBase, ExpressibleByDictionaryLiteral
{
    public typealias Key = K
    public typealias Value = V

    public var keys: [K]
    {
        get
        {
            let r = Auburn.redis!
            let maybeResult = try? r.hkeys(key: self.key)
            
            guard let results = maybeResult as? [RedisType]
            else
            {
                print("\nNil result from HKEYS command.\n")
                return []
            }
            
            guard results.isEmpty == false
            else
            {
                print("\nResult array from HKEYS command is empty.\n")
                return []
            }
            
            return convert(resultArray: results) ?? []
        }
    }
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
            _ = try? r.hset(key: key, field: itemKey, value: value)
        }
    }
    
    public required convenience init(dictionary: Dictionary<String, V>)
    {
        self.init()

        guard let r = Auburn.redis else
        {
            return
        }

        _ = try? r.sendCommand("del", values: [key])

        for (itemKey, value) in dictionary
        {
            _ = try? r.hset(key: key, field: itemKey, value: value)
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
                    return result as? V
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
            _ = try? r.hset(key: self.key, field: key, value: fieldValue)
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
        
        guard let mysteryResult = hincrbyResult
            else
        {
            return nil
        }
        
        if "\(type(of: mysteryResult))" == "NSNull"
        {
            return nil
        }
        
        switch mysteryResult
        {
        case let datableResult as Datable:
            let resultAsInt:Int?
             
             switch datableResult
             {
             case let dataResult as Data:
                 let stringFromData = dataResult.string
                 resultAsInt = Int(stringFromData)
             case let stringResult as String:
                 resultAsInt = Int(stringResult)
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
                 return (actualInt as! V)
             case "String":
                 return (String(actualInt) as! V)
             case "Data":
                 return (actualInt.data as! V)
             case "Float":
                 return (Float(actualInt) as! V)
             case "Double":
                 return (Double(actualInt) as! V)
            default:
                 return nil
             }
        case let maybeDatableResult as MaybeDatable:
            let resultAsInt:Int?
             
             switch maybeDatableResult
             {
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
                 return (actualInt as! V)
             case "String":
                 return (String(actualInt) as! V)
             case "Data":
                 return (actualInt.data as! V)
             case "Float":
                 return (Float(actualInt) as! V)
             case "Double":
                 return (Double(actualInt) as! V)
            default:
                 return nil
             }
        default:
            return nil
        }
        
        
    }
    
    func convert(resultArray: [RedisType]) -> [K]?
    {
        if resultArray.isEmpty
        {
            return nil
        }
        else
        {
            var convertedObjects = [K]()
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
    
    // FIXME: Only works if field keys are the same type as the map key
    func convert(result: RedisType) -> K?
    {
        let typeString = "\(K.self)"
        switch typeString
        {
        case "String":
            switch result
            {
            case let dataResult as Data:
                return dataResult.string as? K
            case let stringResult as String:
                return stringResult as? K
            default:
                return result as? K
            }
        case "Data":
            switch result
            {
            case let dataResult as Data:
                return dataResult as? K
            case let stringResult as String:
                return stringResult.data as? K
            default:
                return nil
            }
        case "Int":
            switch result
            {
            case let dataResult as Data:
                return Int(dataResult.string) as? K
            case let stringResult as String:
                return Int(stringResult) as? K
            case let intResult as Int:
                return intResult as? K
            default:
                return nil
            }
        case "Float":
            switch result
            {
            case let dataResult as Data:
                return Float(dataResult.string) as? K
            case let stringResult as String:
                return Float(stringResult) as? K
            case let floatResult as Float:
                return floatResult as? K
            default:
                return nil
            }
        case "Double":
            switch result
            {
            case let dataResult as Data:
                return Double(dataResult.string) as? K
            case let stringResult as String:
                return Double(stringResult) as? K
            case let doubleResult as Double:
                return doubleResult as? K
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}
