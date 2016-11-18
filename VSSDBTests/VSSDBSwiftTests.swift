//
//  VSSDBSwiftTests.swift
//  VSSDB
//
//  Created by Valo on 2016/11/18.
//  Copyright © 2016年 Valo. All rights reserved.
//

import XCTest

class VSSDBSwiftTests: VSSDBTests {
    func testExample() {
        let ret = self.vssdb.set("1", data: "A".data(using: .utf8))
        let d = self.vssdb.get("1")
        let s = String(data: d!, encoding: .utf8)
        print("set: \(ret) , get: \(s)")
    }
}
