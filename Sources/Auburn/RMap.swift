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
            //_ = try? r.hset(key: key, field: String(describing: itemKey), value: String(describing: value))
        }
    }

    public subscript(key: K) -> V?
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
                    default:
                        return String(describing: result) as? V
                }
            case "Int":
                switch result
                {
                    case let dataResult as Data:
                        return Int(data: dataResult) as? V
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
                        //return Float(dataResult.string) as? V
                    case let stringResult as String:
                        return Float(stringResult) as? V
                    case let floatResult as Float:
                        return floatResult as? V
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
                    case let doubleResult as Double:
                        return doubleResult as? V
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
                    default:
                        return nil
                }
            default:
                return nil
        }
    }
}
