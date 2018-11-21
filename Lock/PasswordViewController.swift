//
//  PasswordViewController.swift
//  Lock
//
//  Created by yong hu on 18/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftSocket
import SwiftMessages

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var origin: UITextField!
    
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var confirmP: UITextField!
    @IBOutlet weak var newP: UITextField!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var OKButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OKButton.layer.cornerRadius=5
        CancelButton.layer.cornerRadius=5
        self.title="修改密码"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

    @IBAction func ConfirmButtonClicked(_ sender: Any) {
        if (origin.text?.isEmpty)! || (newP.text?.isEmpty)! || (confirmP.text?.isEmpty)! || (self.phone.text?.isEmpty)!{
            let alert = UIAlertController(title: "Alert", message: "不能为空", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
                // Code in this block will trigger when OK button tapped.
                print("Ok button tapped");
                
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if newP.text != confirmP.text{
            let alert = UIAlertController(title: "Alert", message: "确认密码相同", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
                // Code in this block will trigger when OK button tapped.
                print("Ok button tapped");
                
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let username=gUserName
        let password=self.newP.text!
        let phone=self.phone.text!
        let name=gUserName
        let type:[UInt8]=[0x01]
        var _userName:[UInt8]=Array(username.utf8)
        var _password:[UInt8]=Array(password.utf8)
        var _phone:[UInt8]=Array(phone.utf8)
        var _name:[UInt8]=Array(name.utf8)
        for _ in _userName.count..<16{
            _userName.append(0x00)
        }
        for _ in _password.count..<16{
            _password.append(0x00)
        }
        for _ in _phone.count..<12{
            _phone.append(0x00)
        }
        for _ in _name.count..<12{
            _name.append(0x00)
        }
        let message=_userName+_userName+_password+_phone+_name+type
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x16,0x62,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x16,0x62,0xff]+message+byteArray+[0x7e])
        
        
        Log.login(gUserName, "修改密码")
        switch client.send(data:data ) {
        case .success:
            sleep(1)
            guard let rdata = client.read(1024*10) else { return }
            
            if rdata[0] == 0x7e
            {
                
                let response=rdata[20]
                if response == 0xFF{
                    //faild
                    loadFaild()
                }else if response == 0x11{
                    let error = MessageView.viewFromNib(layout: .tabView)
                    error.configureTheme(.error)
                    error.configureContent(title: "错误", body: "电话号码重复!")
                    
                    
                }else{
                    Toast.show(message: "修改成功！", controller: self)
                }
                
                
            }
            
        case .failure(let error):
            loadFaild()
            print(error)
        }
    }
    
}
