import RedShot

public class Auburn {
    static var _redis: Redis?
    static var redis: Redis? {
        get {
            if _redis == nil {
                _redis = try? Redis(hostname: "localhost", port: 6379)
            }
            
            return _redis
        }
    }
}

