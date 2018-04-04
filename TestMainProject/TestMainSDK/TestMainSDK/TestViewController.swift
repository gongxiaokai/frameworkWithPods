//
//  TestViewController.swift
//  TestMainSDK
//
//  Created by gongwenkai on 2018/4/4.
//  Copyright © 2018 gongwenkai. All rights reserved.
//

import UIKit
import BlocksKit
import SnapKit

public typealias ActionHandle = (_ vc : UIViewController, _ btn: UIButton)->()

open class TestViewController: UIViewController {

    var testBtnActionHandel : ActionHandle?
    
    lazy var testBtn : UIButton = {
        let btn = UIButton.init()
        btn.setTitle("sdkTestBtn", for: .normal)
        btn.backgroundColor = UIColor.red
        return btn
    }()
    
    lazy var tipsLab : UILabel = {
        let lab = UILabel.init()
        lab.text = "SDK ViewController"
        lab.font = UIFont.systemFont(ofSize: 20)
        return lab
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        // Do any additional setup after loading the view.
    }
    
    func setupStyle() {
        view.backgroundColor = UIColor.green
        
        view.addSubview(tipsLab)
        tipsLab.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(200)
        }
        
        
        view.addSubview(testBtn)
        testBtn.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
        testBtn.bk_addEventHandler({ [weak self] (btn) in
            print("click sdk testBtn")
            guard let `self` = self else { return}
            if let handle = self.testBtnActionHandel {
                handle(self, btn as! UIButton)
            }
        }, for: .touchUpInside)
    }
}
