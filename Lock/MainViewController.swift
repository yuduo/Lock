//
//  MainViewController.swift
//  Lock
//
//  Created by yong hu on 2018/11/9.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var quiteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        quiteButton.layer.cornerRadius=5
        check()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
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
            let Version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            //let build = dictionary["CFBundleVersion"] as! String
            if (verCode - Float(Version)! > 0) {
                let alert = UIAlertController(title: "有新版本", message: "是否更新？", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "是", style: .default) { (action:UIAlertAction!) in
                    
                    // Code in this block will trigger when OK button tapped.
                    print("Ok button tapped");
                    let url=URL(string: "https://itunes.apple.com/cn/app/%E4%BA%A8%E9%80%9A%E9%97%A8%E7%A6%81/id1448235015?ls=1&mt=8")
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url!)
                    }
                }
                alert.addAction(OKAction)
                let cancelAction = UIAlertAction(title: "否", style: .default) { (action:UIAlertAction!) in
                    
                    // Code in this block will trigger when OK button tapped.
                    print("cancelAction button tapped");
                    
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        task.resume()
    }
    @IBAction func exitClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
}
