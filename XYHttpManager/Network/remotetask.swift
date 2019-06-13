//
//  remotetask.swift
//  FJBiotechnology
//
//  Created by gu yingjiong on 2019/3/10.
//  Copyright © 2019 peng. All rights reserved.
//

import Foundation

public typealias MGTaskComplete = (MGAPIResult) -> Void

public typealias MGDeserializer = (Data?, URLResponse?, Error?) -> MGAPIResult
typealias MGSerializer = (inout Dictionary<String, Any>) -> URLRequest


func Deserializer(d: Data?, _: URLResponse?, _: Error?)-> MGAPIResult{
  do{
    if d == nil{        
        return MGAPIResult(withStateCode: -1, bussinessState: "-1", dataResult: Dictionary<String,Any>(), context: nil)
    }
    
    guard let objFromJson : [String:Any] = try JSONSerialization.jsonObject(with: d!) as? [String : Any] else{
        return MGAPIResult(withStateCode: -1, bussinessState: "-1", dataResult: Dictionary<String,Any>(), context: nil)
    }
    //let resps = objFromJson as! [String:Any]
    return MGAPIResult(withStateCode: 200, bussinessState: "0000", dataResult: objFromJson, context: nil)
  } catch {
    return MGAPIResult(withStateCode: -1, bussinessState: "-1", dataResult: [String:Any](), context: nil)
  }
}

open class MGHttpAPITask: NSObject {
  let s = URLSession.shared
  var _request:URLRequest? = nil
  
  init(with request:URLRequest) {
    _request = request
  }
  
  var _deserializer:MGDeserializer? = nil
  
  public func cfg(add deserializer:@escaping MGDeserializer)->MGHttpAPITask {
    _deserializer = deserializer
    return self
  }
  
  weak var _runningTask:URLSessionTask? = nil
  
  open func exc(completionHandler: MGTaskComplete? = nil)->MGHttpAPITask{
    weak var weakSelf = self
    _runningTask = s.dataTask(with: _request!) { (respData, urlResp, err) in
      guard weakSelf != nil else { return}
      guard let callback = completionHandler else { return }
      
      weakSelf!._runningTask = nil
      let r = (weakSelf?._deserializer!(respData, urlResp, err))!
      DispatchQueue.main.async {
        callback(r)
      }
    }
    _runningTask!.resume()
    return self
  }
  
  open func cancel()->Bool {
    guard let t = _runningTask else { return false }
    guard !(t.state == .completed || t.state == .canceling) else { return false }
    t.cancel()
    return true
  }
}


open class MGAPIResult: NSObject {
  let _httpState:Int
  let _bussinessState:String
  let _result:Dictionary<String, Any>?
  let _ctx:Dictionary<String, Any>?
  
  public var httpState:Int {get {return _httpState} }
  public var bussinessState:String {get {return _bussinessState}}
  public var result:Dictionary<String, Any>? {get {return _result}}
  public var context:Dictionary<String, Any>? {get {return _ctx}}
  
  // TODO:
  // 1 finish follower function
  // 2 Outer application is not directly deppency this sdk, the facade sdk which contain UI is, whether outer application want custome all of the UI.
  public var isSucc:Bool = false  // todo it
  public var errMsg:String? = nil
  var fatoLoginStateCodes:Set<String> = ["1100"]
  public var fatolLoginState:Bool {
    get{
      return fatoLoginStateCodes.contains(_bussinessState)
    }
  }
  //  public var originResult:Dictionary<String, Any>? = nil
  // TODO: end
  
  public init(withStateCode httpStat:Int, bussinessState state:String, dataResult:Dictionary<String, Any>?, context:Dictionary<String, Any>?) {
    _httpState = httpStat
    _bussinessState = state
    _result = dataResult
    _ctx = context
    
    let succ = (state  == "0000" )
    isSucc = succ
    if succ == false {
      let errObj = (context?["msg"] ?? context?["error"])
      errMsg = "\(String( describing: errObj ))"
    }
  }
}
