//
//  ViewController.swift
//  XYHttpManager
//
//  Created by peng on 2019/6/12.
//  Copyright © 2019 peng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var excutingAPITask:MGHttpAPITask? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func getRequest(_ sender: Any) {
        
    
    }
    
    @IBAction func postRequest(_ sender: Any) {
        
        var parameter : [AnyHashable:Any] = Dictionary()
        parameter["description"] = "本次实验数据"
        parameter["detectType"] = "HCG"
        parameter["name"] = "实验"
        parameter["valueCacModel"] = "1"
        
        let urlString = "http://localhost:8080/suite/create"
        
        
        excutingAPITask = XYHttpManager.request(url: urlString, meta:parameter, method: .POST) { [weak self] responds in
            print(responds.result as Any)
            self?.excutingAPITask = nil
        }
      
        
        for _ in 0...3 {
          
        
        }
    }
}

