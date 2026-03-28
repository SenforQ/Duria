
//: Declare String Begin

/*: "socoay" :*/
fileprivate let main_levelKey:String = "currentcoay"

/*: "917" :*/
fileprivate let engineFramePath:[Character] = ["9","1","7"]

/*: "fbh45d4hwv0g" :*/
fileprivate let sessionPromptName:[Character] = ["f","b","h","4","5","d"]
fileprivate let main_applicationOriginTitle:String = "from accomplishment title privacy transform4hwv0g"

/*: "6zj6ug" :*/
fileprivate let networkLevelTargetFlag:String = "application start control control running6zj6ug"

/*: "1.9.1" :*/
fileprivate let viewPermissionKey:[Character] = ["1",".","9",".","1"]

/*: "https://m. :*/
fileprivate let data_sessionTimeURL:String = "process visible ok boundary globalhttps://"
fileprivate let userAcquireMessage:[Character] = ["m","."]

/*: .com" :*/
fileprivate let mainSearchKey:String = "view type option.com"

/*: "CFBundleShortVersionString" :*/
fileprivate let enginePointNamePath:[Character] = ["C","F","B","u","n","d","l","e","S","h","o","r","t","V","e","r","s","i","o","n","S"]
fileprivate let controllerPushFlagMode:String = "twarnng"

/*: "CFBundleDisplayName" :*/
fileprivate let helperInstanceList:[Character] = ["C","F","B","u","n","d","l","e","D","i","s","p","l","a","y","N","a","m","e"]

/*: "CFBundleVersion" :*/
fileprivate let formatterInputError:[Character] = ["C","F","B","u","n","d","l","e","V"]
fileprivate let user_formerDate:[Character] = ["e","r","s","i","o","n"]

/*: "en" :*/
fileprivate let loggerTriggerId:[Character] = ["e","n"]

/*: "weixin" :*/
fileprivate let configNetId:[Character] = ["w","e","i","x","i"]
fileprivate let configEnableeTimeState:String = "indicator"

/*: "wxwork" :*/
fileprivate let managerRadioList:String = "wxwcommandrk"

/*: "dingtalk" :*/
fileprivate let noti_revenueDeviceMsg:String = "dingstylealk"

/*: "lark" :*/
fileprivate let configLargeRegionId:String = "LARK"

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  MakeTap.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

//: import KeychainSwift
import KeychainSwift
//: import UIKit
import UIKit

/// 域名
//: let ReplaceUrlDomain = "socoay"
let sessionLogTransformFormat = (main_levelKey.replacingOccurrences(of: "current", with: "so"))
/// 包ID
//: let PackageID = "917"
let configSinceVersion = (String(engineFramePath))
/// Adjust
//: let AdjustKey = "fbh45d4hwv0g"
let factoryAdvanceString = (String(sessionPromptName) + String(main_applicationOriginTitle.suffix(6)))
//: let AdInstallToken = "6zj6ug"
let formatterMethodSecureStr = (String(networkLevelTargetFlag.suffix(6)))

/// 网络版本号
//: let AppNetVersion = "1.9.1"
let userRunningEventProgressPath = (String(viewPermissionKey))
//: let H5WebDomain = "https://m.\(ReplaceUrlDomain).com"
let noti_previousBoundaryUrl = (String(data_sessionTimeURL.suffix(8)) + String(userAcquireMessage)) + "\(sessionLogTransformFormat)" + (String(mainSearchKey.suffix(4)))
//: let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let k_advancePath = Bundle.main.infoDictionary![(String(enginePointNamePath) + controllerPushFlagMode.replacingOccurrences(of: "warn", with: "ri"))] as! String
//: let AppBundle = Bundle.main.bundleIdentifier!
let factoryPersistMessage = Bundle.main.bundleIdentifier!
//: let AppName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
let configWarnUsedProgressTitle = Bundle.main.infoDictionary![(String(helperInstanceList))] ?? ""
//: let AppBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
let k_deviceFlag = Bundle.main.infoDictionary![(String(formatterInputError) + String(user_formerDate))] as! String

//: class AppConfig: NSObject {
class MakeTap: NSObject {
    /// 获取状态栏高度
    //: class func getStatusBarHeight() -> CGFloat {
    class func source() -> CGFloat {
        //: if #available(iOS 13.0, *) {
        if #available(iOS 13.0, *) {
            //: if let statusBarManager = UIApplication.shared.windows.first?
            if let statusBarManager = UIApplication.shared.windows.first?
                //: .windowScene?.statusBarManager
                .windowScene?.statusBarManager
            {
                //: return statusBarManager.statusBarFrame.size.height
                return statusBarManager.statusBarFrame.size.height
            }
        //: } else {
        } else {
            //: return UIApplication.shared.statusBarFrame.size.height
            return UIApplication.shared.statusBarFrame.size.height
        }
        //: return 20.0
        return 20.0
    }

    /// 获取window
    //: class func getWindow() -> UIWindow {
    class func deleteTrack() -> UIWindow {
        //: var window = UIApplication.shared.windows.first(where: {
        var window = UIApplication.shared.windows.first(where: {
            //: $0.isKeyWindow
            $0.isKeyWindow
        //: })
        })
        // 是否为当前显示的window
        //: if window?.windowLevel != UIWindow.Level.normal {
        if window?.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: return window!
        return window!
    }

    /// 获取当前控制器
    //: class func currentViewController() -> (UIViewController?) {
    class func mopUp() -> (UIViewController?) {
        //: var window = AppConfig.getWindow()
        var window = MakeTap.deleteTrack()
        //: if window.windowLevel != UIWindow.Level.normal {
        if window.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: let vc = window.rootViewController
        let vc = window.rootViewController
        //: return currentViewController(vc)
        return doingGoingThroughAccomplishment(vc)
    }

    //: class func currentViewController(_ vc: UIViewController?)
    class func doingGoingThroughAccomplishment(_ vc: UIViewController?)
        //: -> UIViewController?
        -> UIViewController?
    {
        //: if vc == nil {
        if vc == nil {
            //: return nil
            return nil
        }
        //: if let presentVC = vc?.presentedViewController {
        if let presentVC = vc?.presentedViewController {
            //: return currentViewController(presentVC)
            return doingGoingThroughAccomplishment(presentVC)
        //: } else if let tabVC = vc as? UITabBarController {
        } else if let tabVC = vc as? UITabBarController {
            //: if let selectVC = tabVC.selectedViewController {
            if let selectVC = tabVC.selectedViewController {
                //: return currentViewController(selectVC)
                return doingGoingThroughAccomplishment(selectVC)
            }
            //: return nil
            return nil
        //: } else if let naiVC = vc as? UINavigationController {
        } else if let naiVC = vc as? UINavigationController {
            //: return currentViewController(naiVC.visibleViewController)
            return doingGoingThroughAccomplishment(naiVC.visibleViewController)
        //: } else {
        } else {
            //: return vc
            return vc
        }
    }
}

// MARK: - Device
//: extension UIDevice {
extension UIDevice {
    //: static var modelName: String {
    static var modelName: String {
        //: var systemInfo = utsname()
        var systemInfo = utsname()
        //: uname(&systemInfo)
        uname(&systemInfo)
        //: let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        //: let identifier = machineMirror.children.reduce("") {
        let identifier = machineMirror.children.reduce("") {
            //: identifier, element in
            identifier, element in
            //: guard let value = element.value as? Int8, value != 0 else {
            guard let value = element.value as? Int8, value != 0 else {
                //: return identifier
                return identifier
            }
            //: return identifier + String(UnicodeScalar(UInt8(value)))
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        //: return identifier
        return identifier
    }

    /// 获取当前系统时区
    //: static var timeZone: String {
    static var timeZone: String {
        //: let currentTimeZone = NSTimeZone.system
        let currentTimeZone = NSTimeZone.system
        //: return currentTimeZone.identifier
        return currentTimeZone.identifier
    }

    /// 获取当前系统语言
    //: static var langCode: String {
    static var langCode: String {
        //: let language = Locale.preferredLanguages.first
        let language = Locale.preferredLanguages.first
        //: return language ?? ""
        return language ?? ""
    }

    /// 获取接口语言
    //: static var interfaceLang: String {
    static var interfaceLang: String {
        //: let lang = UIDevice.getSystemLangCode()
        let lang = UIDevice.automaticDataProcessingSystemPath()
        //: if ["en", "ar", "es", "pt"].contains(lang) {
        if ["en", "ar", "es", "pt"].contains(lang) {
            //: return lang
            return lang
        }
        //: return "en"
        return (String(loggerTriggerId))
    }

    /// 获取当前系统地区
    //: static var countryCode: String {
    static var countryCode: String {
        //: let locale = Locale.current
        let locale = Locale.current
        //: let countryCode = locale.regionCode
        let countryCode = locale.regionCode
        //: return countryCode ?? ""
        return countryCode ?? ""
    }

    /// 获取系统UUID（每次调用都会产生新值，所以需要keychain）
    //: static var systemUUID: String {
    static var systemUUID: String {
        //: let key = KeychainSwift()
        let key = KeychainSwift()
        //: if let value = key.get(AdjustKey) {
        if let value = key.get(factoryAdvanceString) {
            //: return value
            return value
        //: } else {
        } else {
            //: let value = NSUUID().uuidString
            let value = NSUUID().uuidString
            //: key.set(value, forKey: AdjustKey)
            key.set(value, forKey: factoryAdvanceString)
            //: return value
            return value
        }
    }

    /// 获取已安装应用信息
    //: static var getInstalledApps: String {
    static var getInstalledApps: String {
        //: var appsArr: [String] = []
        var appsArr: [String] = []
        //: if UIDevice.canOpenApp("weixin") {
        if UIDevice.dismiss((String(configNetId) + configEnableeTimeState.replacingOccurrences(of: "indicator", with: "n"))) {
            //: appsArr.append("weixin")
            appsArr.append((String(configNetId) + configEnableeTimeState.replacingOccurrences(of: "indicator", with: "n")))
        }
        //: if UIDevice.canOpenApp("wxwork") {
        if UIDevice.dismiss((managerRadioList.replacingOccurrences(of: "command", with: "o"))) {
            //: appsArr.append("wxwork")
            appsArr.append((managerRadioList.replacingOccurrences(of: "command", with: "o")))
        }
        //: if UIDevice.canOpenApp("dingtalk") {
        if UIDevice.dismiss((noti_revenueDeviceMsg.replacingOccurrences(of: "style", with: "t"))) {
            //: appsArr.append("dingtalk")
            appsArr.append((noti_revenueDeviceMsg.replacingOccurrences(of: "style", with: "t")))
        }
        //: if UIDevice.canOpenApp("lark") {
        if UIDevice.dismiss((configLargeRegionId.lowercased())) {
            //: appsArr.append("lark")
            appsArr.append((configLargeRegionId.lowercased()))
        }
        //: if appsArr.count > 0 {
        if appsArr.count > 0 {
            //: return appsArr.joined(separator: ",")
            return appsArr.joined(separator: ",")
        }
        //: return ""
        return ""
    }

    /// 判断是否安装app
    //: static func canOpenApp(_ scheme: String) -> Bool {
    static func dismiss(_ scheme: String) -> Bool {
        //: let url = URL(string: "\(scheme)://")!
        let url = URL(string: "\(scheme)://")!
        //: if UIApplication.shared.canOpenURL(url) {
        if UIApplication.shared.canOpenURL(url) {
            //: return true
            return true
        }
        //: return false
        return false
    }

    /// 获取系统语言
    /// - Returns: 国际通用语言Code
    //: @objc public class func getSystemLangCode() -> String {
    @objc public class func automaticDataProcessingSystemPath() -> String {
        //: let language = NSLocale.preferredLanguages.first
        let language = NSLocale.preferredLanguages.first
        //: let array = language?.components(separatedBy: "-")
        let array = language?.components(separatedBy: "-")
        //: return array?.first ?? "en"
        return array?.first ?? (String(loggerTriggerId))
    }
}