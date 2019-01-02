//
//  MapViewController.swift
//  Lock
//
//  Created by yong hu on 12/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController ,BMKMapViewDelegate,CLLocationManagerDelegate,BMKRouteSearchDelegate{
    var _mapView: BMKMapView?
    let locationManager = CLLocationManager()
    var LocationArray:[Location] = []
    var location:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) );
    var currlocation:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) );
    var name:String=""
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    func onGetDrivingRouteResult(_ searcher: BMKRouteSearch!, result: BMKDrivingRouteResult!, errorCode error: BMKSearchErrorCode) {
        //
        var array = _mapView!.overlays
        _mapView!.removeOverlays(array)
        
        if error.rawValue == 0 {
            let plan = result.routes[0] as! BMKDrivingRouteLine
            // 计算路线方案中的路段数目
            let size = plan.steps.count
            var planPointCounts = 0
            for i in 0..<size {
                let transitStep = plan.steps[i] as! BMKDrivingStep

                if i == 0 {
                    let item = BMKPointAnnotation ()
                    item.coordinate = plan.starting.location
                    item.title = "起点"
                    
                    _mapView!.addAnnotation(item)  // 添加起点标注
                }else if i == size - 1 {
                    let item = BMKPointAnnotation ()
                    item.coordinate = plan.terminal.location
                    item.title = "终点"
                    
                    _mapView!.addAnnotation(item)  // 添加终点标注
                }
                
                // 添加 annotation 节点
                let item = BMKPointAnnotation ()
                item.coordinate = transitStep.entrace.location
                item.title = transitStep.instruction
                
                _mapView!.addAnnotation(item)
                // 轨迹点总数累计
                planPointCounts = Int(transitStep.pointsCount) + planPointCounts
            }
            
            
            
            // 轨迹点
            var tempPoints = Array(repeating: BMKMapPoint(x: 0, y: 0), count: planPointCounts)
            var i = 0
            for j in 0..<size {
                let transitStep = plan.steps[j] as! BMKDrivingStep
                for k in 0..<Int(transitStep.pointsCount) {
                    tempPoints[i].x = transitStep.points[k].x
                    tempPoints[i].y = transitStep.points[k].y
                    i+=1
                }
            }
            
            // 通过 points 构建 BMKPolyline
            let polyLine = BMKPolyline(points: &tempPoints, count: UInt(planPointCounts))
            _mapView!.add(polyLine) // 添加路线 overlay
            mapViewFitPolyLine(polyline: polyLine)
        }
    }
    /**
     *根据overlay生成对应的View
     *@param mapView 地图View
     *@param overlay 指定的overlay
     *@return 生成的覆盖物View
     */
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay as! BMKPolyline? != nil {
            let polylineView = BMKPolylineView(overlay: overlay as! BMKPolyline)
            polylineView!.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
            polylineView!.lineWidth = 3
            return polylineView
        }
        return nil
    }
    //根据polyline设置地图范围
    func mapViewFitPolyLine(polyline: BMKPolyline!) {
        if polyline.pointCount < 1 {
            return
        }
        
        let pt = polyline.points[0]
        var ltX = pt.x
        var rbX = pt.x
        var ltY = pt.y
        var rbY = pt.y
        
        for i in 1..<polyline.pointCount {
            let pt = polyline.points[Int(i)]
            if pt.x < ltX {
                ltX = pt.x
            }
            if pt.x > rbX {
                rbX = pt.x
            }
            if pt.y > ltY {
                ltY = pt.y
            }
            if pt.y < rbY {
                rbY = pt.y
            }
        }
        
        let rect = BMKMapRectMake(ltX, ltY, rbX - ltX, rbY - ltY)
        _mapView!.visibleMapRect = rect
        _mapView!.zoomLevel = _mapView!.zoomLevel - 0.3
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
        if (abs(currlocation.latitude-locValue.latitude)>0.01 || abs(currlocation.longitude-locValue.longitude)>0.01){
            currlocation.latitude=locValue.latitude
            currlocation.longitude=locValue.longitude
            
            // 国测局坐标类型的原始坐标
            let gcj02Coord:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
            // 转为百度经纬度类型的坐标
            let bd09Coord:CLLocationCoordinate2D  = BMKCoordTrans(gcj02Coord, BMK_COORD_TYPE(rawValue: 0)!, BMK_COORD_TYPE(rawValue: 2)!)
            
            let loc:BMKUserLocation=BMKUserLocation()
            
            let cl:CLLocation=CLLocation(latitude: bd09Coord.latitude, longitude: bd09Coord.longitude)
            loc.location=cl
            self._mapView?.updateLocationData(loc)
            
            //初始化检索对象
            var _routeSearch = BMKRouteSearch()
            //设置delegate，用于接收检索结果
            _routeSearch.delegate = self;
            //构造驾车查询基础信息类
            var start = BMKPlanNode()
            start.name="当前位置"
            start.cityName="苏州市"
            start.pt=bd09Coord
            var end = BMKPlanNode()
            end.pt=location
            end.name="目的地"
            end.cityName="苏州市"
            var drivingRouteSearchOption = BMKDrivingRoutePlanOption()
            drivingRouteSearchOption.from = start;
            drivingRouteSearchOption.to = end;
            drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
            _routeSearch.drivingSearch(drivingRouteSearchOption)
            
        }
        
        
    }
    
    func addAnnotation(location:CLLocationCoordinate2D,name:String){

        let annotation:BMKPointAnnotation=BMKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(Double(location.latitude), Double(location.longitude));
        annotation.title = name;
        _mapView?.addAnnotation(annotation)

        
    }
    
}
