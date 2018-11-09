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
        self.title="地图方式"
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
        let location:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) );
        _mapView?.setCenter(location, animated: true)
        
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
    @objc func showAnnotation(sender: UIButton) {
        print("Disclosure button clicked")
        let tag=sender.tag
        if LocationArray.count > tag{
            let l=LocationArray[tag]
            
            Socket.openLock(longitude:l.longitude,latutude:l.latutude,lockId:l.id,controller:self)
        }
    }
    // 根据anntation生成对应的View
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        //        //annotation
//        let annotationViewID = "renameMark"
//        var annotationView:BMKPinAnnotationView? = _mapView?.dequeueReusableAnnotationView(withIdentifier: annotationViewID) as? BMKPinAnnotationView
//
//        if(annotationView == nil){
//
//            annotationView = BMKPinAnnotationView.init(annotation:annotation, reuseIdentifier:annotationViewID)
//        }
//
//        //设置颜色
//        //            annotationView?.pinColor = BMKPinAnnotationColorPurple
//        //从天上掉下来效果
//        annotationView!.animatesDrop = true
//        //设置不可拖拽
//        annotationView!.isDraggable = false
//        //annotationView!.image = UIImage(named:"sina")
//        annotationView?.canShowCallout = true
//        let btn=UIButton(type: .detailDisclosure)
//        annotationView?.rightCalloutAccessoryView=btn
//        btn.addTarget(self, action: #selector(MapViewController.showAnnotation), for: .touchUpInside)
//
//        return annotationView
        let reuserId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuserId)
            as? BMKPinAnnotationView
        if pinView == nil {
            //创建一个大头针视图
            pinView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserId)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
           
            //设置大头针点击注释视图的右侧按钮样式
            let btn=UIButton(type: .detailDisclosure)
            btn.addTarget(self, action: #selector(MapViewController.showAnnotation), for: .touchUpInside)
            btn.tag=getTag(annotation.title!(),annotation.subtitle!())
            pinView?.rightCalloutAccessoryView=btn
            
            pinView?.isEnabled=true
            //pinView?.calloutOffset = CGPoint(x: -5, y: 5)
        }else{
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    func getTag(_ title:String,_ subtitle:String)->Int{
        var i:Int=0
        for l in LocationArray{
            i+=1

            if ((l.name==title) && (l.id==subtitle)){
                return i
            }

            
        }
        return 0
    }
    //call out
    func mapView(
        _ mapView: BMKMapView, annotationView view: BMKPinAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callout accessory control triggered!")
        
        let annotation = view.annotation
        if control == view.rightCalloutAccessoryView {
            print("right callout button is clicked")
            let title=String(format: "%s", annotation?.subtitle as! CVarArg)
            Socket.openLock(lockId: title,controller:self)
        }
    }
    func mapView(mapView: BMKMapView, didSelectAnnotationView view: BMKPinAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation as? BMKAnnotation {
            print("Your annotation title: \(annotation.subtitle)");
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
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
                
                    loadSuccess()
                    let loc=Array(response[2...response.count-2])
                    for i in 0...count{
                        var location:Location!=Location()
                        let lon=loc[0...9]
                        let lan=loc[10...19]
                        let id=loc[20...36]
                        let name=loc[37...77]
                        let warning=loc[78]
                        location.longitude=String(data: Data(bytes:lon), encoding: String.Encoding.utf8)!
                        location.latutude=String(data: Data(bytes:lan), encoding: String.Encoding.utf8)!
                        location.id=String(data: Data(bytes:id), encoding: String.Encoding.utf8)!
                        location.name=String(data: Data(bytes:name), encoding: String.Encoding.utf8)!
                        location.warning=Int(warning)
                        LocationArray.append(location)
                        print(location.longitude)
                        print(location.latutude)
                        print(location.id)
                        //Socket.openLock(lockId:location.id)
                        
                    }
                    addAnnotation()
                
                
                
            }else{
                loadFaild()
            }
            
        case .failure(let error):
            print(error)
        }
        
    
    }
    func addAnnotation(){
        for location in LocationArray{
            
            let annotation:BMKPointAnnotation=BMKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(Double(location.latutude)!, Double(location.longitude)!)
            annotation.title = location.name
            annotation.subtitle=location.id
            
            _mapView?.addAnnotation(annotation)
        }
        
    }
    
    
}
