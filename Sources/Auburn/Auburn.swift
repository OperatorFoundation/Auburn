import Foundation
import RedShot
import Datable

public class Auburn
{
    static private let queue: DispatchQueue = DispatchQueue(label: "RedisTransactions")
    static var port = 6380
    static var _redis: Redis?
    static var redis: Redis? {
        get {
            if _redis == nil {
                _redis = try? Redis(hostname: "localhost", port: port)
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
                NSLog("\nUnable to get db filename: No redis connection")
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
        set
        {
            guard let newName = newValue
                else { return }
            guard let r = Auburn.redis else
            {
                NSLog("\nUnable to set db filename: No redis connection")
                return
            }
            
            do
            {
                let response = try r.configSet(key: "dbfilename", value: newName)
                if response == true
                {
                    do
                    {
                        let rewriteResponse = try r.configRewrite()
                        if rewriteResponse == false
                        {
                            print("\nFailed to rewrite config with new db filename.")
                        }
                    }
                }
            }
            catch let error
            {
                print("\nError setting db filename: \(error)")
            }
        }
    }
    
    static public func redisIsRunning() -> Bool
    {
        guard let r = Auburn.redis else
        {
            return false
        }
        
        return(r.ping())
    }
    
    static public func restartRedis()
    {
        _redis = nil
    }
    
    static public func transaction(_ block: (Redis) throws -> Void) -> [RedisType]?
    {
        var result: [RedisType]?
        
        guard let r = Auburn.redis
            else
        {
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
    
    static public func shutdownRedis()
    {
        guard let r = Auburn.redis
            else
        {
            NSLog("\nDid not tr shutdown Redis server: No redis connection")
            return
        }
        
        let _ = r.shutdown()
    }

}
