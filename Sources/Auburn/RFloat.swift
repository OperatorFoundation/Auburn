//
//  RFloat.swift
//  Auburn
//
//  Created by Brandon Wiley on 12/3/17.
//

import Foundation
import RedShot

public final class RFloat: RBase, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Float

    public init(floatLiteral value: Float) {
        super.init()

        guard let r = Auburn.redis else {
            return
        }

        _ = try? r.set(key: key, value: String(value))
    }
}
