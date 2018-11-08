//
//  MapViewController.swift
//  Lock
//
//  Created by yong hu on 12/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController ,BMKMapViewDelegate,CLLocationManagerDelegate{
    var _mapView: BMKMapView?
    let locationManager = CLLocationManager()
    var LocationArray:[Location] = []
    var location:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) );
    var name:String=""
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
        
        
        //显示定位图层
        _mapView?.showsUserLocation = true
        //设置定位的状态为普通定位模式
        _mapView?.userTrackingMode = BMKUserTrackingModeNone
        
        addAnnotation(location: location, name: name)
        _mapView?.setCenter(location, animated: true)
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
    
    func addAnnotation(location:CLLocationCoordinate2D,name:String){

        let annotation:BMKPointAnnotation=BMKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(Double(location.latitude), Double(location.longitude));
        annotation.title = name;
        _mapView?.addAnnotation(annotation)

        
    }
    
}
