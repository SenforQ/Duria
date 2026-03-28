
//: Declare String Begin

/*: "Net Error, Try again later" :*/
fileprivate let modelSceneActiveOriginalValue:[Character] = ["N","e","t"," ","E","r","r","o","r",","," ","T","r","y"," ","a","g","a","i","n"," ","l","a","t","e"]
fileprivate let app_markFormat:String = "stop"

/*: "data" :*/
fileprivate let controllerPilloryUrl:[Character] = ["d","a","t","a"]

/*: ":null" :*/
fileprivate let parserRegionSecret:[Character] = [":","n","u","l","l"]

/*: "json error" :*/
fileprivate let appAssignmentKey:String = "json erand revenue tap"
fileprivate let throughColorLinkMsg:[Character] = ["r","o","r"]

/*: "platform=iphone&version= :*/
fileprivate let serviceAddTrackResult:String = "plerrorfo"
fileprivate let notiFormatValue:String = "target sum re title safeone&"
fileprivate let parserVelleityMode:String = "vscreenrs"

/*: &packageId= :*/
fileprivate let user_valueRunFileID:[Character] = ["&","p"]
fileprivate let againToolGlobalTitle:String = "ackageId=shared field generate"

/*: &bundleId= :*/
fileprivate let dataPhotoSecret:[Character] = ["&"]
fileprivate let appPageRequestName:[Character] = ["b","u","n","d","l","e","I","d","="]

/*: &lang= :*/
fileprivate let show_fatalKey:[Character] = ["&","l","a","n","g","="]

/*: ; build: :*/
fileprivate let serviceLevelStr:String = "fire print; bu"

/*: ; iOS  :*/
fileprivate let show_textCount:String = "; iOS block target process minute"

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit
//: import Alamofire
import Alamofire
//: import CoreMedia
import CoreMedia
//: import HandyJSON
import HandyJSON
 
//: typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: AppErrorResponse?) -> Void
typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: SelectTrim?) -> Void
 
//: @objc class AppRequestTool: NSObject {
@objc class AdaptLength: NSObject {
    /// 发起Post请求
    /// - Parameters:
    ///   - model: 请求参数
    ///   - completion: 回调
    //: class func startPostRequest(model: AppRequestModel, completion: @escaping FinishBlock) {
    class func atFilter(model: RescueOperationModel, completion: @escaping FinishBlock) {
        //: let serverUrl = self.buildServerUrl(model: model)
        let serverUrl = self.begin(model: model)
        //: let headers = self.getRequestHeader(model: model)
        let headers = self.bondRating(model: model)
        //: AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
        AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
            //: switch responseData.result {
            switch responseData.result {
            //: case .success:
            case .success:
                //: func__requestSucess(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                activityText(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                
            //: case .failure:
            case .failure:
                //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "Net Error, Try again later"))
                completion(false, nil, SelectTrim.init(errorCode: PriceTagNotice.NetError.rawValue, errorMsg: (String(modelSceneActiveOriginalValue) + app_markFormat.replacingOccurrences(of: "stop", with: "r"))))
            }
        }
    }
    
    //: class func func__requestSucess(model: AppRequestModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
    class func activityText(model: RescueOperationModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
        //: var responseJson = String(data: responseData, encoding: .utf8)
        var responseJson = String(data: responseData, encoding: .utf8)
        //: responseJson = responseJson?.replacingOccurrences(of: "\"data\":null", with: "\"data\":{}")
        responseJson = responseJson?.replacingOccurrences(of: "\"" + (String(controllerPilloryUrl)) + "\"" + (String(parserRegionSecret)), with: "" + "\"" + (String(controllerPilloryUrl)) + "\"" + ":{}")
        //: if let responseModel = JSONDeserializer<AppBaseResponse>.deserializeFrom(json: responseJson) {
        if let responseModel = JSONDeserializer<EErConsent>.deserializeFrom(json: responseJson) {
            //: if responseModel.errno == RequestResultCode.Normal.rawValue {
            if responseModel.errno == PriceTagNotice.Normal.rawValue {
                //: completion(true, responseModel.data, nil)
                completion(true, responseModel.data, nil)
            //: } else {
            } else {
                //: completion(false, responseModel.data, AppErrorResponse.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                completion(false, responseModel.data, SelectTrim.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                //: switch responseModel.errno {
                switch responseModel.errno {
//                case PriceTagNotice.NeedReLogin.rawValue:
//                    NotificationCenter.default.post(name: DID_LOGIN_OUT_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //: default:
                default:
                    //: break
                    break
                }
            }
        //: } else {
        } else {
            //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "json error"))
            completion(false, nil, SelectTrim.init(errorCode: PriceTagNotice.NetError.rawValue, errorMsg: (String(appAssignmentKey.prefix(7)) + String(throughColorLinkMsg))))
        }
                
    }
    
    //: class func buildServerUrl(model: AppRequestModel) -> String {
    class func begin(model: RescueOperationModel) -> String {
        //: var serverUrl: String = model.requestServer
        var serverUrl: String = model.requestServer
        //: let otherParams = "platform=iphone&version=\(AppNetVersion)&packageId=\(PackageID)&bundleId=\(AppBundle)&lang=\(UIDevice.interfaceLang)"
        let otherParams = (serviceAddTrackResult.replacingOccurrences(of: "error", with: "at") + "rm=iph" + String(notiFormatValue.suffix(4)) + parserVelleityMode.replacingOccurrences(of: "screen", with: "e") + "ion=") + "\(userRunningEventProgressPath)" + (String(user_valueRunFileID) + String(againToolGlobalTitle.prefix(9))) + "\(configSinceVersion)" + (String(dataPhotoSecret) + String(appPageRequestName)) + "\(factoryPersistMessage)" + (String(show_fatalKey)) + "\(UIDevice.interfaceLang)"
        //: if !model.requestPath.isEmpty {
        if !model.requestPath.isEmpty {
            //: serverUrl.append("/\(model.requestPath)")
            serverUrl.append("/\(model.requestPath)")
        }
        //: serverUrl.append("?\(otherParams)")
        serverUrl.append("?\(otherParams)")
        
        //: return serverUrl
        return serverUrl
    }
    
    /// 获取请求头参数
    /// - Parameter model: 请求模型
    /// - Returns: 请求头参数
    //: class func getRequestHeader(model: AppRequestModel) -> HTTPHeaders {
    class func bondRating(model: RescueOperationModel) -> HTTPHeaders {
        //: let userAgent = "\(AppName)/\(AppVersion) (\(AppBundle); build:\(AppBuildNumber); iOS \(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        let userAgent = "\(configWarnUsedProgressTitle)/\(k_advancePath) (\(factoryPersistMessage)" + (String(serviceLevelStr.suffix(4)) + "ild:") + "\(k_deviceFlag)" + (String(show_textCount.prefix(6))) + "\(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        //: let headers = [HTTPHeader.userAgent(userAgent)]
        let headers = [HTTPHeader.userAgent(userAgent)]
        //: return HTTPHeaders(headers)
        return HTTPHeaders(headers)
    }
}
 