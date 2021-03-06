//
//  Random.swift
//  LispKit
//
//  Created by Matthias Zenger on 24/02/2017.
//  Copyright © 2017 ObjectHub. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation


private let maxInt64 = UInt64(Int64.max)

private func arc4random<T: ExpressibleByIntegerLiteral>(_ type: T.Type) -> T {
  var r: T = 0
  arc4random_buf(&r, MemoryLayout<T>.size)
  return r
}

public extension UInt64 {
  public static func random(min: UInt64 = UInt64.min, max: UInt64 = UInt64.max) -> UInt64 {
    // compute random number
    var rand = arc4random(self)
    // fix modulo bias
    let range = max - min
    let m: UInt64 = range > maxInt64 ? (1 + ~range) : (((UInt64.max - (range * 2)) + 1) % range)
    while rand < m {
      rand = arc4random(self)
    }
    return (rand % range) + min
  }
}

public extension Int64 {
  public static func random(min: Int64 = Int64.min, max: Int64 = Int64.max) -> Int64 {
    let (s, overflow) = max.subtractingReportingOverflow(min)
    let u: UInt64 = overflow ? (UInt64.max - UInt64(~s)) : UInt64(s)
    let rand = UInt64.random(max: u)
    return rand > maxInt64 ? Int64(rand - (UInt64(~min) + 1)) : (Int64(rand) + min)
  }
}

public extension UInt32 {
  public static func random(min: UInt32 = UInt32.min, max: UInt32 = UInt32.max) -> UInt32 {
    return arc4random_uniform(max - min) + min
  }
}

public extension Int32 {
  public static func random(min: Int32 = Int32.min, max: Int32 = Int32.max) -> Int32 {
    return Int32(Int64(arc4random_uniform(UInt32(Int64(max) - Int64(min)))) + Int64(min))
  }
}
