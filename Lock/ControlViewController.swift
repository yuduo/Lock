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
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var drop: UIButton!
    let locationManager = CLLocationManager()
    var LocationArray:[Location] = []
    var currentLocation:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) );
    let dropDown = DropDown()
    var response:[UInt8]=[]
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
        
        label.isHidden=true
        drop.isHidden=true
  
        dropDown.anchorView = drop // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: drop.bounds.height)
        dropDown.hide()
        drop.layer.borderWidth=1
        drop.layer.borderColor = UIColor.blue.cgColor
        drop.layer.cornerRadius = 5
        
        let Tap = UITapGestureRecognizer(target: self, action: #selector(LogQueryViewController.Tap))
        self.view.addGestureRecognizer(Tap)
        
        queryLock(latitude:"120.665441" ,longitude:"31.2043183")
        
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
            
            break
            
        }
    }
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        self.peripheral!.discoverServices(nil)
    }
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?) {
        
        
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
            if characteristic.value?.count ?? 0 > 7{
                guard let characteristicData = characteristic.value else { return }
                let byteArray = [UInt8](characteristicData)
                if ((byteArray[0] == 126)&&(byteArray[byteArray.count-1] != 126)){
                    response=byteArray
                    self.peripheral!.writeValue(sendReadIDNext(byte: 0x02), for: characteristic, type: .withoutResponse)
                }else if((byteArray[0] == 126)&&(byteArray[byteArray.count-1] == 126)){
                    
                }
                else{
                    response+=byteArray[2...byteArray.count]
                    self.peripheral!.writeValue(sendReadIDNext(byte: 0x03), for: characteristic, type: .withoutResponse)
                }
                for element in byteArray {
                    print(element, terminator: "")
                }
            }
            if ((response.count > 20)&&(response[response.count-1]==126)){
                let m:[UInt8]=Array(response[10...26])
                var crc=m.crc16()
                let bytePtr = withUnsafePointer(to: &crc) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                        UnsafeBufferPointer(start: $0, count: 2)
                    }
                }
                let byteArray = Array(bytePtr)
                sendOpenLock(message: byteArray, for:characteristic)
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print(peripheral.name)
            
            if peripheral.name!.range(of:"iODS775") != nil{
                self.peripheral=peripheral
                self.peripheral!.delegate=self
                self.manager.connect(self.peripheral!, options: nil)
                self.manager.stopScan()
            }
        }
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
        
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x61,0xff]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x61,0xff]+message+byteArray+[0x7e])
        self.peripheral!.writeValue(data, for: characteristic, type: .withoutResponse)
        Toast.show(message: "开锁成功！", controller: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        label.isHidden=true
        drop.isHidden=true
        dropDown.hide()
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
        
        
        manager.scanForPeripherals(withServices: nil, options: nil)
        
        
        
    }
    
    @IBAction func helpClicked(_ sender: Any) {
        dropDown.dataSource = getLocks()
        dropDown.show()
        label.isHidden=false
        drop.isHidden=false
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.drop.setTitle(item, for: .normal)
            Socket.openLock(longitude: String(format:"%f",(self?.currentLocation.longitude)!),latutude: String(format:"%f",(self?.currentLocation.latitude)!),lockId: (self?.LocationArray[index].id)!,controller:self!)
        }
    }
    
    @IBAction func remoteClicked(_ sender: Any) {
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
        currentLocation.latitude=locValue.latitude
        currentLocation.longitude=locValue.longitude
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
                if (response.count < 4){
                    return
                }
                loadSuccess()
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
                    
                }
                
                
                
                
            }else{
                loadFaild()
            }
            
        case .failure(let error):
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}
