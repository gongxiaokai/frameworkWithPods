//
//  TestMainSDK.swift
//  TestMainSDK
//
//  Created by gongwenkai on 2018/4/4.
//  Copyright © 2018 gongwenkai. All rights reserved.
//

import Foundation


open class TestMainSDK {
    
    //singleton
    open static let shared = TestMainSDK()
    
    open static let testParam = 999
    
    open func testFun() {
        print("from sdk testFun()")
    }

    
    open func getSDKviewController(vcHandle: (TestViewController)->(),
                                   actionHandle: ActionHandle?){
        let vc = TestViewController()
        vc.testBtnActionHandel = actionHandle
        vcHandle(vc)
    }
}
