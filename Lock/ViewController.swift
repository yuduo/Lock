//
//  ViewController.swift
//  Lock
//
//  Created by yong hu on 08/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftSocket
import SwiftMessages

let client = TCPClient(address:
    "47.99.47.199",

                       //"192.168.1.52",
    port: 5002)

class ViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userName.text="pm8"
        password.text="m"
        loginButton.layer.cornerRadius=5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
        //performSegue(withIdentifier: "loginSegue", sender: nil)
        var u=userName.text!
        var p=password.text!
//        u="wtlz0001"
//        p="wtlz0001"
//        u="pm8"
//        p="m"

        var _userName:[UInt8]=Array(u.utf8)
        var _password:[UInt8]=Array(p.utf8)
        
        
        for _ in _userName.count..<16{
            _userName.append(0x00)
        }
        for _ in _password.count..<16{
            _password.append(0x00)
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        print(dateString)
        let timer:[UInt8]=Array("12:10:00".utf8)
        let message=_userName+_password+timer
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x62,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x62,0xff]+message+byteArray+[0x7e])
        
        
        
        switch client.connect(timeout: 60) {
        case .success:
            switch client.send(data:data ) {
            case .success:
                sleep(1)
                guard let rdata = client.read(1024*10) else { return }
                if rdata[0] == 0x7e
                {
                    let response=Array(rdata[20...rdata.count-1])
                    if response[0] == 0x00{
                        //faild
                        loadFaild()
                    }else if response[0] == 0x03 ||  response[0] == 0x04{
                        loadSuccess()
                        if response[0] == 0x03{
                            let time=response[4...11]
                            let lock=String(data: Data(bytes:response[12...response.count-3]), encoding: String.Encoding.utf8)
                        }
                        
                        
                        Socket.uploadLog(content: "登录", target: "pm8")
                        performSegue(withIdentifier: "loginSegue", sender: nil)
                    }else {
                        
                    }
                    
                    
                }
                
            case .failure(let error):
                print("send data faild")
            }
        case .failure(let error):
            print("connect faild")
        }
        
    }
    
    
}

