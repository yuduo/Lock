//
//  MapViewController.swift
//  Lock
//
//  Created by yong hu on 12/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftSocket
import SwiftMessages
class MapViewController: UIViewController ,BMKMapViewDelegate,CLLocationManagerDelegate{
    var _mapView: BMKMapView?
    let locationManager = CLLocationManager()
    var LocationArray:[Location] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _mapView = BMKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(_mapView!)
        _mapView?.delegate=self
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        queryLock(latitude: "120.665441",longitude: "31.2043183");
        
        
        //显示定位图层
        _mapView?.showsUserLocation = true
        //设置定位的状态为普通定位模式
        _mapView?.userTrackingMode = BMKUserTrackingModeNone
        
        
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _mapView?.viewWillAppear()
        _mapView?.delegate = self  // 此处记得不用的时候需要置nil，否则影响内存的释放
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView?.viewWillDisappear()
        _mapView?.delegate = nil // 不用时，置nil
    }
    
    // 根据anntation生成对应的View
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        //        //annotation
        let annotationViewID = "renameMark"
        var annotationView:BMKPinAnnotationView? = _mapView?.dequeueReusableAnnotationView(withIdentifier: annotationViewID) as? BMKPinAnnotationView
        
        if(annotationView == nil){
            
            annotationView = BMKPinAnnotationView.init(annotation:annotation, reuseIdentifier:annotationViewID)
        }
        
        //设置颜色
        //            annotationView?.pinColor = BMKPinAnnotationColorPurple
        //从天上掉下来效果
        annotationView!.animatesDrop = true
        //设置不可拖拽
        annotationView!.isDraggable = false
        annotationView!.image = UIImage(named:"sina")
        return annotationView
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
    }
    
    func queryLock(latitude:String,longitude:String){
        var message:[UInt8]=[]
        var _latitude:[UInt8]=Array(latitude.utf8)
        var _longitude:[UInt8]=Array(longitude.utf8)
        
        
        for _ in _latitude.count..<10{
            _latitude.append(0x00)
        }
        for _ in _longitude.count..<10{
            _longitude.append(0x00)
        }
        let rang="0.0100"
        message=_latitude+_longitude+Array(rang.utf8)
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x06,0x62,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x06,0x62,0xff]+message+byteArray+[0x7e])
        
        
        
        switch client.send(data:data ) {
        case .success:
            sleep(1)
            guard let rdata = client.read(1024*10) else { return }
            let cdata = Array(rdata[20...21])
            let count:Int16=Int16((UInt16(cdata[1]) << 8) + UInt16(cdata[0]))
            if rdata[0] == 0x7e
            {
                
                let response=Array(rdata[20...rdata.count-3])
                
                    let success = MessageView.viewFromNib(layout: .cardView)
                    success.configureTheme(.success)
                    success.configureDropShadow()
                    success.configureContent(title: "Success", body: "Something good happened!")
                    success.button?.isHidden = true
                    var successConfig = SwiftMessages.defaultConfig
                    successConfig.presentationStyle = .center
                    
                    SwiftMessages.show(config: successConfig, view: success)
                    let loc=Array(response[2...response.count-2])
                    for i in 0...count{
                        var location:Location!=Location()
                        let lon=loc[0...9]
                        let lan=loc[10...19]
                        let id=loc[20...26]
                        let name=loc[26...76]
                        let warning=loc[77]
                        location.longitude=String(data: Data(bytes:lon), encoding: String.Encoding.utf8)!
                        location.latutude=String(data: Data(bytes:lan), encoding: String.Encoding.utf8)!
                        location.id=String(data: Data(bytes:id), encoding: String.Encoding.utf8)!
                        location.name=String(data: Data(bytes:name), encoding: String.Encoding.utf8)!
                        location.warning=Int(warning)
                        LocationArray.append(location)
                        print(location.longitude)
                        print(location.latutude)
                        print(location.id)
                        openLock(lockId:location.id)
                        openLock(longitude:location.longitude,latutude:location.latutude,lockId:location.id)
                    }
                    addAnnotation()
                
                
                
            }else{
                let error = MessageView.viewFromNib(layout: .tabView)
                error.configureTheme(.error)
                error.configureContent(title: "Error", body: "Something is horribly wrong!")
                
                
                SwiftMessages.show(view: error)
            }
            
        case .failure(let error):
            print(error)
        }
        
    
    }
    func addAnnotation(){
        for location in LocationArray{
            
            let annotation:BMKPointAnnotation=BMKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(Double(location.latutude)!, Double(location.longitude)!);
            annotation.title = location.name;
            _mapView?.addAnnotation(annotation)
        }
        
    }
    func openLock(lockId:String){
        let username="pm"
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
        
        
        
        switch client.send(data:data ) {
        case .success:
            sleep(1)
            guard let rdata = client.read(1024*10) else { return }
            
            if rdata[0] == 0x7e
            {
                
                let response=rdata[20]
                if response == 1{
                    //faild
                    let error = MessageView.viewFromNib(layout: .tabView)
                    error.configureTheme(.error)
                    error.configureContent(title: "Error", body: "Something is horribly wrong!")
                    
                    
                    SwiftMessages.show(view: error)
                }else {
                    let success = MessageView.viewFromNib(layout: .cardView)
                    success.configureTheme(.success)
                    success.configureDropShadow()
                    success.configureContent(title: "Success", body: "Something good happened!")
                    success.button?.isHidden = true
                    var successConfig = SwiftMessages.defaultConfig
                    successConfig.presentationStyle = .center
                    
                    SwiftMessages.show(config: successConfig, view: success)
                    
                }
                
                
            }
            
        case .failure(let error):
            print(error)
        }
    }
    func openLock(longitude:String,latutude:String,lockId:String){
        let username="pm"
        var _userName:[UInt8]=Array(username.utf8)
        
        for _ in _userName.count..<16{
            _userName.append(0x00)
        }
        let message=Array(longitude.utf8)+Array(latutude.utf8)+_userName+Array(lockId.utf8)
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
                    let error = MessageView.viewFromNib(layout: .tabView)
                    error.configureTheme(.error)
                    error.configureContent(title: "Error", body: "Something is horribly wrong!")
                    
                    
                    SwiftMessages.show(view: error)
                }else {
                    let success = MessageView.viewFromNib(layout: .cardView)
                    success.configureTheme(.success)
                    success.configureDropShadow()
                    success.configureContent(title: "Success", body: "Something good happened!")
                    success.button?.isHidden = true
                    var successConfig = SwiftMessages.defaultConfig
                    successConfig.presentationStyle = .center
                    
                    SwiftMessages.show(config: successConfig, view: success)
                    
                }
                
                
            }
            
        case .failure(let error):
            print(error)
        }
    }
}
