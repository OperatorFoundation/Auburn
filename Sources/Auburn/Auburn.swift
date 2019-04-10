import Foundation
import RedShot
import Datable

public class Auburn
{
    static var _redis: Redis?
    static var redis: Redis? {
        get {
            if _redis == nil {
                _redis = try? Redis(hostname: "localhost", port: 6379)
            }

            return _redis
        }
    }
    
    static public var dbfilename: String?
    {
        get
        {
            guard let r = Auburn.redis else
            {
                NSLog("No redis connection")
                return nil
            }
            
            do
            {
                let response = try r.configGet(key: "dbfilename")
                
                guard let responseArray = response as? [Data]
                else
                {
                    return nil
                }
                
                
                return responseArray[1].string
            }
            catch let error
            {
                print("\nError getting dbfilename: \(error)")
                return nil
            }
        }
    }
    
    static private let queue: DispatchQueue = DispatchQueue(label: "RedisTransactions")
    
    static public func transaction(_ block: (Redis) throws -> Void) -> [RedisType]?
    {
        var result: [RedisType]?
        
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return nil
        }

        queue.sync {
            do {
                try r.multi()
                try block(r)
                result = try r.exec()
            } catch {
            }
        }
        
        return result
    }

}
