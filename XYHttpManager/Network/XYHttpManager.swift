//
//  XYHttpManager.swift
//  XYHttpManager
//
//  Created by peng on 2019/6/12.
//  Copyright © 2019 peng. All rights reserved.
//

import UIKit

enum NetworkMethod {
    case GET
    case POST
}

class XYHttpManager: NSObject {
    
    static var sharedManager: XYHttpManager {
        let tool = XYHttpManager()
        return tool
    }

}

extension XYHttpManager{
    class func request(url:String, meta:[AnyHashable : Any], method:NetworkMethod, callBack:@escaping MGTaskComplete)->MGHttpAPITask{

        let httpBody = XYHttpManager.jsonStringWith(parameters: meta)
        var req = URLRequest(url: URL(string: url)!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if(method == NetworkMethod.GET){
             req.httpMethod = "GET"
        }else if(method == NetworkMethod.POST){
             req.httpMethod = "POST"
        }
        req.httpBody = httpBody
        return MGHttpAPITask(with: req).cfg(add: Deserializer).exc(completionHandler: callBack)
    }
    
    class func jsonStringWith(parameters:[AnyHashable : Any])->Data {
  

        let data = try! JSONSerialization.data(withJSONObject: parameters, options: [])

        let newStr = String(data: data, encoding: String.Encoding.utf8)
        print(newStr as Any)
        return data
    }
}
