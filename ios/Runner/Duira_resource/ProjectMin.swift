
//: Declare String Begin

/*: "init(coder:) has not been implemented" :*/
fileprivate let helperVisibleWarnPhoneStr:[UInt8] = [0xc6,0xc1,0xc6,0xdb,0x87,0xcc,0xc0,0xcb,0xca,0xdd,0x95,0x86,0x8f,0xc7,0xce,0xdc,0x8f,0xc1,0xc0,0xdb,0x8f,0xcd,0xca,0xca,0xc1,0x8f,0xc6,0xc2,0xdf,0xc3,0xca,0xc2,0xca,0xc1,0xdb,0xca,0xcb]

private func transformInput(receive num: UInt8) -> UInt8 {
    return num ^ 175
}

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  ProjectMin.swift
//  AbroadTalking
//
//  Created by Joeyoung on 2022/9/1.
//

//: import UIKit
import UIKit

//: let kProgressHUD_W            = 80.0
let sessionDeviceResult            = 80.0
//: let kProgressHUD_cornerRadius = 14.0
let engineAreaIntervalervalToken = 14.0
//: let kProgressHUD_alpha        = 0.9
let modelLiveError        = 0.9
//: let kBackgroundView_alpha     = 0.6
let parserMonitorPersistTitle     = 0.6
//: let kAnimationInterval        = 0.2
let enginePreviousReadingData        = 0.2
//: let kTransformScale           = 0.9
let mainNetChangeMessage           = 0.9

//: open class ProgressHUD: UIView {
open class ProjectMin: UIView {
    //: required public init?(coder: NSCoder) {
    required public init?(coder: NSCoder) {
        //: fatalError("init(coder:) has not been implemented")
        fatalError(String(bytes: helperVisibleWarnPhoneStr.map{transformInput(receive: $0)}, encoding: .utf8)!)
    }
    
    //: static var shared = ProgressHUD()
    static var shared = ProjectMin()
    //: private override init(frame: CGRect) {
    private override init(frame: CGRect) {
        //: super.init(frame: frame)
        super.init(frame: frame)
        //: self.frame = UIScreen.main.bounds
        self.frame = UIScreen.main.bounds
        //: self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //: self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        //: self.addSubview(activityIndicator)
        self.addSubview(activityIndicator)
    }
    //: open override func copy() -> Any { return self }
    open override func copy() -> Any { return self }
    //: open override func mutableCopy() -> Any { return self }
    open override func mutableCopy() -> Any { return self }
    
    //: class func show() {
    class func event() {
        //: show(superView: nil)
        doDecide(superView: nil)
    }
    //: class func show(superView: UIView?) {
    class func doDecide(superView: UIView?) {
        //: if superView != nil {
        if superView != nil {
            //: DispatchQueue.main.async {
            DispatchQueue.main.async {
                //: ProgressHUD.shared.frame = superView!.bounds
                ProjectMin.shared.frame = superView!.bounds
                //: ProgressHUD.shared.activityIndicator.center = ProgressHUD.shared.center
                ProjectMin.shared.activityIndicator.center = ProjectMin.shared.center
                //: superView!.addSubview(ProgressHUD.shared)
                superView!.addSubview(ProjectMin.shared)
            }
        //: } else {
        } else {
            //: DispatchQueue.main.async {
            DispatchQueue.main.async {
                //: ProgressHUD.shared.frame = UIScreen.main.bounds
                ProjectMin.shared.frame = UIScreen.main.bounds
                //: ProgressHUD.shared.activityIndicator.center = ProgressHUD.shared.center
                ProjectMin.shared.activityIndicator.center = ProjectMin.shared.center
                //: AppConfig.getWindow().addSubview(ProgressHUD.shared)
                MakeTap.deleteTrack().addSubview(ProjectMin.shared)
            }
        }
        //: ProgressHUD.shared.hud_startAnimating()
        ProjectMin.shared.exaggerate()
    }
    //: class func dismiss() {
    class func path() {
        //: ProgressHUD.shared.hud_stopAnimating()
        ProjectMin.shared.remote()
    }
    
    //: private func hud_startAnimating() {
    private func exaggerate() {
        //: DispatchQueue.main.async {
        DispatchQueue.main.async {
            //: self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            //: self.activityIndicator.transform = CGAffineTransform(scaleX: kTransformScale, y: kTransformScale)
            self.activityIndicator.transform = CGAffineTransform(scaleX: mainNetChangeMessage, y: mainNetChangeMessage)
            //: self.activityIndicator.alpha = 0
            self.activityIndicator.alpha = 0
            //: UIView.animate(withDuration: kAnimationInterval) {
            UIView.animate(withDuration: enginePreviousReadingData) {
                //: self.backgroundColor = UIColor(white: 0, alpha: kBackgroundView_alpha)
                self.backgroundColor = UIColor(white: 0, alpha: parserMonitorPersistTitle)
                //: self.activityIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.activityIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                //: self.activityIndicator.alpha = kProgressHUD_alpha
                self.activityIndicator.alpha = modelLiveError
                //: self.activityIndicator.startAnimating()
                self.activityIndicator.startAnimating()
            }
        }
    }
    //: private func hud_stopAnimating() {
    private func remote() {
        //: DispatchQueue.main.async {
        DispatchQueue.main.async {
            //: UIView.animate(withDuration: kAnimationInterval) {
            UIView.animate(withDuration: enginePreviousReadingData) {
                //: self.backgroundColor = UIColor(white: 0, alpha: 0)
                self.backgroundColor = UIColor(white: 0, alpha: 0)
                //: self.activityIndicator.transform = CGAffineTransform(scaleX: kTransformScale, y: kTransformScale)
                self.activityIndicator.transform = CGAffineTransform(scaleX: mainNetChangeMessage, y: mainNetChangeMessage)
                //: self.activityIndicator.alpha = 0
                self.activityIndicator.alpha = 0
            //: } completion: { finished in
            } completion: { finished in
                //: self.activityIndicator.stopAnimating()
                self.activityIndicator.stopAnimating()
                //: ProgressHUD.shared.removeFromSuperview()
                ProjectMin.shared.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Lazy load
    //: private lazy var activityIndicator: UIActivityIndicatorView = {
    private lazy var activityIndicator: UIActivityIndicatorView = {
        //: let indicator = UIActivityIndicatorView(style: .whiteLarge)
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        //: indicator.bounds = CGRect(x: 0, y: 0, width: kProgressHUD_W, height: kProgressHUD_W)
        indicator.bounds = CGRect(x: 0, y: 0, width: sessionDeviceResult, height: sessionDeviceResult)
        //: indicator.center = self.center
        indicator.center = self.center
        //: indicator.backgroundColor = .black
        indicator.backgroundColor = .black
        //: indicator.layer.cornerRadius = kProgressHUD_cornerRadius
        indicator.layer.cornerRadius = engineAreaIntervalervalToken
        //: indicator.layer.masksToBounds = true
        indicator.layer.masksToBounds = true
        //: return indicator
        return indicator
    //: }()
    }()
}

//: extension ProgressHUD {
extension ProjectMin {
    //: class func toast(_ str: String?) {
    class func purchase(_ str: String?) {
        //: toast(str, showTime: 1)
        push(str, showTime: 1)
    }
    //: class func toast(_ str: String?, showTime: CGFloat) {
    class func push(_ str: String?, showTime: CGFloat) {
        //: guard str != nil else { return }
        guard str != nil else { return }
                
        //: let titleLab = UILabel()
        let titleLab = UILabel()
        //: titleLab.backgroundColor = UIColor(white: 0, alpha: 0.8)
        titleLab.backgroundColor = UIColor(white: 0, alpha: 0.8)
        //: titleLab.layer.cornerRadius = 5
        titleLab.layer.cornerRadius = 5
        //: titleLab.layer.masksToBounds = true
        titleLab.layer.masksToBounds = true
        //: titleLab.text = str
        titleLab.text = str
        //: titleLab.font = .systemFont(ofSize: 16)
        titleLab.font = .systemFont(ofSize: 16)
        //: titleLab.textAlignment = .center
        titleLab.textAlignment = .center
        //: titleLab.numberOfLines = 0
        titleLab.numberOfLines = 0
        //: titleLab.textColor = .white
        titleLab.textColor = .white
        //: AppConfig.getWindow().addSubview(titleLab)
        MakeTap.deleteTrack().addSubview(titleLab)
        //: let size = titleLab.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat(MAXFLOAT)))
        let size = titleLab.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat(MAXFLOAT)))
        //: titleLab.center = AppConfig.getWindow().center
        titleLab.center = MakeTap.deleteTrack().center
        //: titleLab.bounds = CGRect(x: 0, y: 0, width: size.width + 30, height: size.height + 30)
        titleLab.bounds = CGRect(x: 0, y: 0, width: size.width + 30, height: size.height + 30)
        //: titleLab.alpha = 0
        titleLab.alpha = 0
        
        //: UIView.animate(withDuration: 0.2) {
        UIView.animate(withDuration: 0.2) {
            //: titleLab.alpha = 1
            titleLab.alpha = 1
        //: } completion: { finished in
        } completion: { finished in
            //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + showTime) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + showTime) {
                //: UIView.animate(withDuration: 0.2) {
                UIView.animate(withDuration: 0.2) {
                    //: titleLab.alpha = 1
                    titleLab.alpha = 1
                //: } completion: { finished in
                } completion: { finished in
                    //: titleLab.removeFromSuperview()
                    titleLab.removeFromSuperview()
                }
            }
        }
    }
}