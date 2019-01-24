//
//  VersionController .swift
//  Lock
//
//  Created by 朱炜 on 2019/1/23.
//  Copyright © 2019年 yong hu. All rights reserved.
//

import Foundation

class VersionController: UIViewController {
    
    @IBOutlet weak var viewtext: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        check()
        // Do any additional setup after loading the view.
    }
    
    
    private func check(){
        
        let url = URL(string:"http://47.99.47.199:8080/iODS_Lock/iOSApp/ver.json")//URL(string: String(format: "http://%s:%s/iODS_Lock/AndroidApp/ver.json","server.NMSAdrres","server.NMSPort"))
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        //let postString = String(format: "from=0&to=2&x=%f&y=%f",longitude,latitude)
        //request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            let verCode=jsonResult["verCode"] as! Float
            //let url=jsonResult["url"] as! String
            
            DispatchQueue.main.async{
                self.viewtext.text="当前版本是:V"+String( verCode)
                }
            
            
        }
        task.resume()
    }

    
}
