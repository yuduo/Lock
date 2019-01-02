//
//  ControlViewController.swift
//  Lock
//
//  Created by yong hu on 2018/10/31.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import DropDown

import CoreBluetooth

class ControlViewController: UIViewController,CLLocationManagerDelegate ,CBCentralManagerDelegate ,CBPeripheralDelegate{
    
    var manager: CBCentralManager!
    var peripheral:CBPeripheral?
    var _characteristic: CBCharacteristic?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var drop: UIButton!
    let locationManager = CLLocationManager()
    var LocationArray:[Location] = []
    var currentLocation:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) );
    let dropDown = DropDown()
    var response:[UInt8]=[]
    var isConnected=false
    var peripheralArray:[CBPeripheral]=[]
    let peripheralDropDown = DropDown()
    var bd09Coord:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) )
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title="门禁控制"
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
//        label.isHidden=true
//        drop.isHidden=true
  
        dropDown.anchorView = drop // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: drop.bounds.height)
        dropDown.hide()
        drop.layer.borderWidth=1
        drop.layer.borderColor = UIColor.blue.cgColor
        drop.layer.cornerRadius = 5
        
        peripheralDropDown.anchorView = drop // UIView or UIBarButtonItem
        peripheralDropDown.bottomOffset = CGPoint(x: 0, y: drop.bounds.height)
        peripheralDropDown.hide()
        peripheralDropDown.layer.borderWidth=1
        peripheralDropDown.layer.borderColor = UIColor.blue.cgColor
        peripheralDropDown.layer.cornerRadius = 5
        
//        let Tap = UITapGestureRecognizer(target: self, action: #selector(LogQueryViewController.Tap))
//        self.view.addGestureRecognizer(Tap)
        
        
        manager = CBCentralManager(delegate: self, queue: nil ,options:nil)
        
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: break
        // manager.scanForPeripherals(withServices: nil, options: nil)
        case .unknown: break
            
        case .resetting: break
            
        case .unsupported: break
            
        case .unauthorized: break
            
        case .poweredOff:
            Toast.show(message: "请打开蓝牙！", controller: self)
            break
            
        }
    }
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        self.peripheral!.discoverServices(nil)
        isConnected=true
        Toast.show(message: "连接成功！", controller: self)
    }
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?) {
        isConnected=false
        
    }
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == CBUUID(string: "FFE0")  {
                peripheral.discoverCharacteristics(
                    nil,
                    for: thisService
                )
            }
        }
    }
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == CBUUID(string: "FFE1") {
                //self.peripheral?.readValue(for: characteristic)
                self.peripheral!.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
                self.peripheral!.writeValue(sendReadID(), for: characteristic, type: .withoutResponse)
                Toast.show(message: "发送数据！", controller: self)
            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?) {
        print(characteristic.value ?? "no value")
        let v=characteristic.value
        
    }
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?) {
        
        if characteristic.uuid == CBUUID(string: "FFE1") {
            print(characteristic.value ?? "no value")
            if characteristic.value?.count ?? 0 == 1{
                response.removeAll()
                self.manager.cancelPeripheralConnection(self.peripheral!)
                return
            }
            if characteristic.value?.count ?? 0 > 7{
                guard let characteristicData = characteristic.value else { return }
                let byteArray = [UInt8](characteristicData)
                if ((byteArray[0] == 126)&&(byteArray[byteArray.count-1] != 126)){
                    response=byteArray
                    self.peripheral!.writeValue(sendReadIDNext(byte: 0x01), for: characteristic, type: .withoutResponse)
                }else if((byteArray[0] == 126)&&(byteArray[byteArray.count-1] == 126)){
                    
                }else if((byteArray[0] == 255)&&(byteArray[byteArray.count-1] == 255)){
                    if response.count > 0{
                        if ((response[0]==126)&&(response[response.count-1]==126)){
//                            let alert = UIAlertController(title: "", message: "是否开锁？", preferredStyle: UIAlertControllerStyle.alert)
//                            let OKAction = UIAlertAction(title: "是", style: .default) { (action:UIAlertAction!) in
//                                let m:[UInt8]=Array(self.response[10...26])
//                                var crc=m.crc16()
//                                let bytePtr = withUnsafePointer(to: &crc) {
//                                    $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
//                                        UnsafeBufferPointer(start: $0, count: 2)
//                                    }
//                                }
//                                let byteArray = Array(bytePtr)
//                                self.sendOpenLock(message: byteArray, for:characteristic)
//
//                                // Code in this block will trigger when OK button tapped.
//                                print("Ok button tapped");
//
//                            }
//                            alert.addAction(OKAction)
//                            alert.addAction(UIAlertAction(title: "否", style: UIAlertActionStyle.cancel, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
//                            return
//                        }else{
                            response.removeAll()
                            self.manager.cancelPeripheralConnection(self.peripheral!)
                            return
                        }
                    }
                    
                    
                }
                else{
                    response+=byteArray[2...byteArray.count-1]
                    if byteArray[0]>byteArray[1]{
                        self.peripheral!.writeValue(sendReadIDNext(byte: 0x02), for: characteristic, type: .withoutResponse)
                    }
                }
                for element in byteArray {
                    print(element, terminator: "")
                }
                
                if ((response.count > 20)&&(response[response.count-1]==126)){
                    Toast.show(message: "请求开锁！", controller: self)
                    let m:[UInt8]=Array(response[10...26])
                    var crc=m.crc16()
                    let bytePtr = withUnsafePointer(to: &crc) {
                        $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                            UnsafeBufferPointer(start: $0, count: 2)
                        }
                    }
                    let byteArray = Array(bytePtr)
                    _characteristic=characteristic
                    sendOpenLock(message: byteArray, for:characteristic)
                    
                }
            }
            
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print(peripheral.name)
            
            if peripheral.name!.range(of:"iO") != nil{
                Toast.show(message: "发现设备！", controller: self)

                peripheralArray.append(peripheral)
                
                peripheralDropDown.dataSource = getPeripherals()
                peripheralDropDown.show()
                // Action triggered on selection
                peripheralDropDown.selectionAction = { [weak self] (index, item) in
                    self?.peripheralDropDown.hide()
                    self?.peripheral=self!.peripheralArray[index]
                    self?.peripheral!.delegate=self
                    self?.manager.connect((self?.peripheral!)!, options: nil)
                    self?.manager.stopScan()
                    
                }
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //
        isConnected=false
        
    }
    private func sendReadID()->Data{
        let m:[UInt8]=[0x00,0x10, 0x01,0x00,0x01,0x00,0x02,0x61,0xff]
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x01,0x00,0x01,0x00,0x02,0x61,0xff]+[0x0f,0x67]+[0x7e])
        return data
    }
    private func sendReadIDNext(byte:UInt8)->Data{
        let message:[UInt8]=[byte]
        let m:[UInt8]=[0x00,0x10, 0x01,0x00,0x01,0x00,0x02,0x61,0x6c]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x01,0x00,0x01,0x00,0x02,0x61,0x6c]+message+byteArray+[0x7e])
        return data
    }
    private func sendOpenLock(message:[UInt8] ,for characteristic: CBCharacteristic){
        
        let m:[UInt8]=[0x00,0x10, 0x01,0x00,0x01,0x00,0x01,0x61,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x01,0x00,0x01,0x00,0x01,0x61,0xff]+message+byteArray+[0x7e])
        self.peripheral!.writeValue(data, for: characteristic, type: .withoutResponse)
        Toast.show(message: "开锁成功！", controller: self)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //queryLock(latitude:String(currentLocation.latitude) ,longitude:String(currentLocation.longitude))
        //queryLock(latitude:"120.665441" ,longitude:"31.2043183")
//        label.isHidden=true
//        drop.isHidden=true
        dropDown.hide()
        
        if offLine{
            
        }else{
            
        }
        
        
    }
    @objc func Tap(sender:UITapGestureRecognizer) {
        label.isHidden=true
        drop.isHidden=true
        dropDown.hide()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func directClicked(_ sender: Any) {
        
        Log.login(gUserName, "直联开锁")
        
        if isConnected{
//            if ((response.count > 20)&&(response[response.count-1]==126)){
//                let m:[UInt8]=Array(response[10...26])
//                var crc=m.crc16()
//                let bytePtr = withUnsafePointer(to: &crc) {
//                    $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
//                        UnsafeBufferPointer(start: $0, count: 2)
//                    }
//                }
//                let byteArray = Array(bytePtr)
//
//                sendOpenLock(message: byteArray, for:_characteristic!)
//
//            }
            
            Toast.show(message: "断开蓝牙！", controller: self)
            response.removeAll()
            self.manager.cancelPeripheralConnection(self.peripheral!)
        }else{
            peripheralArray.removeAll()
            manager.scanForPeripherals(withServices: nil, options: nil)
            Toast.show(message: "搜索蓝牙！", controller: self)
            
        }
        
        
        
    }
    
    @IBAction func helpClicked(_ sender: Any) {
        Log.login(gUserName, "求助开锁")
        dropDown.dataSource = getLocks()
        dropDown.show()
        label.isHidden=false
        drop.isHidden=false
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.drop.setTitle(item, for: .normal)
            Socket.openLock(longitude: String(format:"%f",(self?.bd09Coord.longitude)!),latitude: String(format:"%f",(self?.bd09Coord.latitude)!),lockId: (self?.LocationArray[index].id)!,controller:self!)
        }
    }
    
    @IBAction func remoteClicked(_ sender: Any) {
        Log.login(gUserName, "远程开锁")
        dropDown.dataSource = getLocks()
        dropDown.show()
        label.isHidden=false
        drop.isHidden=false
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.drop.setTitle(item, for: .normal)
            Socket.openLock(lockId: (self?.LocationArray[index].id)!,controller:self!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if ((abs(currentLocation.latitude-locValue.latitude)>0.01) || (abs(currentLocation.longitude-locValue.longitude)>0.01)){
            currentLocation.latitude=locValue.latitude
            currentLocation.longitude=locValue.longitude
            //translate(locValue.longitude,locValue.latitude)
            // 国测局坐标类型的原始坐标
            let gcj02Coord:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
            // 转为百度经纬度类型的坐标
            bd09Coord = BMKCoordTrans(gcj02Coord, BMK_COORD_TYPE(rawValue: 0)!, BMK_COORD_TYPE(rawValue: 2)!)
            //self.currentLocation.latitude=bd09Coord.latitude
            //self.currentLocation.longitude=bd09Coord.longitude
            self.queryLock(latitude:String(bd09Coord.latitude) ,longitude:String(bd09Coord.longitude))
        }
        
    }
    private func queryLock(latitude:String,longitude:String){
        
        var message:[UInt8]=[]
        var _latitude:[UInt8]=Array(latitude.prefix(10).utf8)
        var _longitude:[UInt8]=Array(longitude.prefix(10).utf8)
        
        if _latitude.count > 10{
            _latitude=Array(latitude.prefix(10).utf8)
        }
        if _longitude.count > 10{
            _longitude=Array(longitude.prefix(10).utf8)
        }
        for _ in _latitude.count..<10{
            _latitude.append(0x00)
        }
        for _ in _longitude.count..<10{
            _longitude.append(0x00)
        }
        let rang="0.0100"
        message=_longitude+_latitude+Array(rang.utf8)
        //message=[0x31 ,0x31 ,0x33 ,0x2e ,0x33 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x34 ,0x30 ,0x2e ,0x31 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x30 ,0x2e ,0x30 ,0x31 ,0x31 ,0x00]
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
            let count:Int16=Int16((UInt8(cdata[1]) << 8) + UInt8(cdata[0]))
            if rdata[0] == 0x7e
            {
                
                let response=Array(rdata[20...rdata.count-3])
                if (response.count < 4){
                    return
                }
                loadSuccess()
                LocationArray.removeAll()
                let loc=Array(response[2...response.count-2])
                for i in 0..<count{
                    var location:Location!=Location()
                    var s:Int=Int(0+i*88)
                    var e:Int=Int(9+i*88)
                    let lon=loc[s...e]
                    s=Int(10+i*88)
                    e=Int(19+i*88)
                    let lan=loc[s...e]
                    s=Int(20+i*88)
                    e=Int(36+i*88)
                    let id=loc[s...e]
                    s=Int(37+i*88)
                    e=Int(86+i*88)
                    let name=loc[s...e]
                    
                    let warning=loc[Int(87+i*88)]
                    location.longitude=String(data: Data(bytes:lon), encoding: String.Encoding.utf8)!
                    location.latutude=String(data: Data(bytes:lan), encoding: String.Encoding.utf8)!
                    location.id=String(data: Data(bytes:id), encoding: String.Encoding.utf8)!
                    location.name=String(data: Data(bytes:name), encoding: String.Encoding.utf8)!
                    location.warning=Int(warning)
                    LocationArray.append(location)
                    print(location.longitude)
                    print(location.latutude)
                    print(location.id)
                    
                }
                
                
                
                dropDown.dataSource = getLocks()
                if dropDown.dataSource.count > 0{
                    self.drop.setTitle(dropDown.dataSource[0], for: .normal)
                }
                dropDown.selectionAction = { [weak self] (index, item) in
                    self?.drop.setTitle(item, for: .normal)
                    
                }
            }else{
                loadFaild("查询失败")
            }
            
        case .failure(let error):
            loadFaild("发送失败")
            print(error)
        }
        
        
    }
    func getLocks()->[String]{
        var list:[String]=[]
        for location in LocationArray{
            list.append(location.name)
        }
        return list
    }
    func getPeripherals()->[String]{
        var list:[String]=[]
        for peripheral in peripheralArray{
            list.append(peripheral.name!)
        }
        return list
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    @IBAction func dropClicked(_ sender: Any) {
        dropDown.show()
    }
    private func translate(_ longitude:Double,_ latitude:Double){
        //var url=String(format: "http://api.map.baidu.com/ag/coord/convert?from=0&to=2&x=%f&y=%f",longitude,latitude)
        
        let url = URL(string: String(format: "http://api.map.baidu.com/ag/coord/convert?from=0&to=2&x=%f&y=%f",longitude,latitude))!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
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
            let er=jsonResult["error"] as! Int
            if (er == 0){
                let x=jsonResult["x"] as! String
                let y=jsonResult["y"] as! String
                print(x.base64Decoded())
                print(y.base64Decoded())
                self.currentLocation.latitude=Double(y.base64Decoded())!
                self.currentLocation.longitude=Double(x.base64Decoded())!
                self.queryLock(latitude:String(self.currentLocation.latitude) ,longitude:String(self.currentLocation.longitude))
            }
            
        }
        task.resume()
    }
    
}
