iOS开发 使用Pods管理调试个人Framework

# 写在前面

>最近换了新公司，又是一个巨大的挑战

>一是海外项目，二是协同，三是使用Swift

>虽说Swift4.0已经很新了，但ABI的稳定进程还是放在了5.0，加上之前几乎没怎么用过Swift做过什么大型项目，都是小打小闹的一些东西。所以本文都是使用的Swift

>由于项目还要与国外的小伙伴合作，一些private的东西公司也不打算直接给他们，这不，就让我们做成library的形式提供给他们，对于我们来说也就是Framework了。

>很快这个任务就落到我头上了，前期踩坑基本都是参照这篇比较新的文章
[手把手教你高效快捷的创建Swift Framework](https://juejin.im/post/5a5269a3f265da3e347b15de) 这篇已经几乎把该用到的内容都讲了。


我这边就主要讲一讲Framework的调试,包含第三方库的集成，目前使用的还是pod，
carthage就暂时不说了，理论上比pod要更方便使用

# 准备工作

新建一个主工程，新建一个Framework工程

>正常情况下，我们一般会对主工程进行`pod install`安装一些主工程需要的第三方库，制作Framework的过程中发现有些地方其实也是需要使用这些第三方，pod已经生成了workspace，这就需要编写Podfile，增加对Framework工程target的支持

打开主工程的workspace 这时候我们的工程是这样的

![主工程](http://imgurl.xyz/images/2018/04/04/36CD0461-89C6-42CB-B9A1-E33FE7E64E54.jpg)

我们将Framework工程拷贝到主工程文件目录中

![工程目录](http://imgurl.xyz/images/2018/04/04/3bdc3d3185088803.png)

# 编写Podfile

注意！ 下面就要开始编写Podfile文件了

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'TestMainProject.xcworkspace'              #指定workspace
inhibit_all_warnings!        #忽略警告
use_frameworks!

def commpod                     #宏定义几个target都要用的的pod
    pod 'MJRefresh'            #下拉刷新
    pod 'Alamofire', '~> 4.0'  #网络请求
    pod 'SnapKit', '~> 4.0.0'   #autolayout
    pod 'ObjectMapper', '~> 3.1'   #json 转模型
    pod 'SVProgressHUD', '~> 2.0.3'
    pod 'BlocksKit'            #将delegate转换为block的库
end


target 'TestMainProject' do
    project 'TestMainProject'
    commpod
    pod 'IQKeyboardManagerSwift' #使用iQ键盘
    pod 'SDWebImage'           #图片离线缓存类
    pod 'AWSS3', '~> 2.6.0'    #AWSS3上传下载
    pod 'IQActionSheetPickerView', '~>2.0.0'  #picker选择器
end


target 'TestMainSDK' do
    project 'TestMainSDK/TestMainSDK'
    commpod
end
```

修改好podfile后直接执行`pod install`

这时候再打开workspace文件就会看到

![workspace](http://imgurl.xyz/images/2018/04/04/workspace.png)

至此SDK已经加入pods的管理中

# 测试

## 测试一

下面就来测试下

再framework工程中加入测试代码

```swift
open class TestMainSDK {

    //singleton
    open static let shared = TestMainSDK()

    open static let testParam = 999

    open func testFun() {
        print("from sdk testFun()")
    }
}
```

先选择framework的scheme 编译一下

![build SDK](http://imgurl.xyz/images/2018/04/04/buildSDK60696.png)

主工程中 `import TestMainSDK`

加入测试代码

```swift
import UIKit
import TestMainSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        TestMainSDK.shared.testFun()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
```

scheme选择主工程，跑一下

![test](http://imgurl.xyz/images/2018/04/04/test.png)


大功告成~

## 测试二

>我们现在要做的是:
- 主程序调用SDK获得一个vc 并 present
- 该vc中有一个按钮，点击事件的具体实现由主程序实现dismiss


在SDK中创建一个`TestViewController` 引入`SnapKit` `BlocksKit`

加入如下代码

```swift
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


    override open func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        // Do any additional setup after loading the view.
    }

    func setupStyle() {
        view.backgroundColor = UIColor.green
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
```

接下来在SDK入口加入获取vc的代码

```swift
open func getSDKviewController(vcHandle: (TestViewController)->(),
                               actionHandle: ActionHandle?){
    let vc = TestViewController()
    vc.testBtnActionHandel = actionHandle
    vcHandle(vc)
}
```

编译一下SDK

在主程序中调用SDK

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    TestMainSDK.shared.testFun()

    let btn = UIButton.init()
    btn.backgroundColor = UIColor.black
    btn.setTitle("mainBtn", for: .normal)
    view.addSubview(btn)
    btn.snp.makeConstraints{$0.center.equalToSuperview()}

    btn.bk_addEventHandler({ (b) in
        TestMainSDK.shared.getSDKviewController(vcHandle: { (vc ) in
            self.present(vc, animated: true, completion: nil)
        }, actionHandle: { (vc , btn) in
            vc.dismiss(animated: true, completion: nil)
        })
    }, for: .touchUpInside)
}

```

选择主程序 跑一下

看下效果

![效果](http://imgurl.xyz/images/2018/04/04/demo.gif)


# 后记

 demo已上传[Github](https://github.com/gongxiaokai/frameworkWithPods)

 跟盆友一起搞的小博客有兴趣的可以看看，此文也会同步过去，也包含一些服务器相关的内容，

 [小胖博客](http://www.xpblog.xyz/)
