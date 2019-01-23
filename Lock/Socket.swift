//
//  Socket.swift
//  Lock
//
//  Created by yong hu on 19/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftSocket
class Socket: NSObject {
    static func uploadLog(content:String,target:String) {
        let username=gUserName
        
        var _userName:[UInt8]=Array(username.utf8)
        let _content:[UInt8]=Array(content.utf8)
        let _target:[UInt8]=Array(target.utf8)
        
        for _ in _userName.count..<16{
            _userName.append(0x00)
        }
        let _contentLen:[UInt8]=[UInt8(_content.count)]
        let _targetLen:[UInt8]=[UInt8(_target.count)]
        let separator:[UInt8]=[0x1d]
        let c:[UInt8]=separator+_contentLen+_content
        let t:[UInt8]=separator+_targetLen+_target
        let message:[UInt8]=_userName+c+t
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x10,0x62,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x10,0x62,0xff]+message+byteArray+[0x7e])
        
        
        
        switch client.send(data:data ) {
        case .success:
            sleep(1)
            guard let rdata = client.read(1024*10) else { return }
            
            if rdata[0] == 0x7e
            {
                
                
                
                
            }
            
        case .failure(let error):
            print(error)
        }
    
    }
    
    class func openLock(longitude:String,latitude:String,lockId:String, controller: UIViewController){
        let username=gUserName
        var _userName:[UInt8]=Array(username.utf8)
        var _latitude:[UInt8]=Array(latitude.prefix(10).utf8)
        var _longitude:[UInt8]=Array(longitude.prefix(10).utf8)
        for _ in _userName.count..<16{
            _userName.append(0x00)
        }
        for _ in _latitude.count..<10{
            _latitude.append(0x00)
        }
        for _ in _longitude.count..<10{
            _longitude.append(0x00)
        }
        
        let lockIddata = lockId.data(using: String.Encoding.utf8)
        let message=Array(_longitude)+Array(_latitude)+Array(lockIddata!)+_userName
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x62,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x62,0xff]+message+byteArray+[0x7e])
        
        
        
        switch client.send(data:data ) {
        case .success:
            sleep(1)
            guard let rdata = client.read(1024*10) else { return }
            
            if rdata[0] == 0x7e
            {
                
                let response=rdata[20]
                if response != 0{
                    //faild
                    Toast.show(message: "请求失败！", controller: controller)
                }else {
                    Toast.show(message: "请求开锁成功！", controller: controller)
                    
                }
                
                
            }
            
        case .failure(let error):
            print(error)
        }
    }
    
    class func openLock(lockId:String, controller: UIViewController){
        let username=gUserName
        var _userName:[UInt8]=Array(username.utf8)
        
        for _ in _userName.count..<16{
            _userName.append(0x00)
        }
        let message=_userName+Array(lockId.utf8)
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x62,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x62,0xff]+message+byteArray+[0x7e])
        
        
        let sv = UIViewController.displaySpinner(onView: controller.view)
        
        switch client.send(data:data ) {
        case .success:
            sleep(1)
            guard let rdata = client.read(1024*10) else {
                UIViewController.removeSpinner(spinner: sv)
                return
                
            }
            
            if rdata[0] == 0x7e
            {
                
                let response=rdata[20]
                if response == 1{
                    //faild
                    Toast.show(message: "收到指令！", controller: controller)
                    
                    guard let tdata = client.read(1024*10,timeout: 10) else {
                        UIViewController.removeSpinner(spinner: sv)
                        return
                        
                    }
                    if tdata[0] == 0x7e
                    {
                        
                        let response=tdata[20]
                        if response == 0{
                            Toast.show(message: "远程开锁成功！", controller: controller)
                        }else{
                            Toast.show(message: "远程开锁失败！", controller: controller)
                        }
                    }
                    UIViewController.removeSpinner(spinner: sv)
                } else{
                    Toast.show(message: "请求失败！", controller: controller)
                    UIViewController.removeSpinner(spinner: sv)
                }
                
                
            }
            
        case .failure(let error):
            UIViewController.removeSpinner(spinner: sv)
            print(error)
        }
    }
}
