//
//  RBase.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/3/17.
//

import Foundation
import RedShot

public class RBase
{
    var _key: String
    public var key: String
    {
        get {
            return _key
        }

        set(newValue) {
            let oldValue = _key
            _key = newValue

            persistent=true

            keyChanged(oldValue: oldValue, newValue: newValue)
        }
    }

    public var persistent: Bool = true

    public init() {
        self._key = UUID().uuidString
        persistent=false
    }

    public init(key: String) {
        self._key = key
        persistent=true
    }

    deinit {
        if !persistent {
            self.delete()
        }
    }

    func keyChanged(oldValue: String, newValue: String) {
        // Both a new and old key, we should rename
        guard let r = Auburn.redis else {
            NSLog("No redis connection")
            return
        }

        _ = try? r.sendCommand("rename", values: [oldValue, newValue])
    }

    public func delete() {
        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.sendCommand("del", values: [key])
    }
}
