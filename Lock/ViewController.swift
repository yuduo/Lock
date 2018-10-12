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
class ViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
        var u=userName.text!
        var p=password.text!
        
        
        for _ in u.count..<16{
            u+="0"
        }
        for _ in p.count..<16{
            p+="0"
        }
        
        let _userName:[UInt8]=Array(u.utf8)
        let _password:[UInt8]=Array(p.utf8)
        print(_userName)
        print(_userName.count)
        print(_password)
        print(_password.count)
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        print(dateString)
        
        let message=u+p+"12:10:00"
        var crc=message.bytes.crc16()
        print(crc)
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x10,0x00, 0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x62,0x01,0xff]+message.bytes+byteArray+[0x7e])
        print(data)
        
        let client = TCPClient(address: "47.99.47.199", port: 5002)
        switch client.connect(timeout: 10) {
        case .success:
            switch client.send(data:data ) {
            case .success:
                guard let data = client.read(1024*10) else { return }
                
                if let response = String(bytes: data, encoding: .utf8) {
                    print(response)
                }
            case .failure(let error):
                print(error)
            }
        case .failure(let error):
            print(error)
        }
        
    }
    

}

