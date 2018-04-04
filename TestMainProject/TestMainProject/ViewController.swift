//
//  ViewController.swift
//  TestMainProject
//
//  Created by gongwenkai on 2018/4/4.
//  Copyright © 2018 gongwenkai. All rights reserved.
//

import UIKit
import TestMainSDK
import BlocksKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        TestMainSDK.shared.testFun()
        
        let tipslab = UILabel.init()
        tipslab.text = "Main ViewController"
        tipslab.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(tipslab)
        tipslab.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(200)
        }
        
        let btn = UIButton.init()
        btn.backgroundColor = UIColor.black
        btn.setTitle("mainBtn", for: .normal)
        view.addSubview(btn)
        btn.snp.makeConstraints{$0.center.equalToSuperview()}
        
        btn.bk_addEventHandler({ (b) in
            TestMainSDK.shared.getSDKviewController(vcHandle: { (vc ) in
                self.present(vc, animated: true, completion: nil)
            }, actionHandle: { (vc , btn) in
                print("handle from mainVC")
                vc.dismiss(animated: true, completion: nil)
            })
        }, for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

