//
//  ControlViewController.swift
//  Lock
//
//  Created by yong hu on 2018/10/31.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import DropDown
import BluetoothKit
import CoreBluetooth
class ControlViewController: UIViewController,CLLocationManagerDelegate ,BKPeripheralDelegate,BKCentralDelegate,BKAvailabilityObserver,CBCentralManagerDelegate ,CBPeripheralDelegate{
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        //
        if availability == .available {
            scan()
        } else {
            //central.interruptScan()
        }
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        //
    }
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        //
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        //
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        //
    }
    
    var manager: CBCentralManager!
    var peripheral:CBPeripheral!
    //let central = BKCentral()
    //let peripheral = BKPeripheral()
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var drop: UIButton!
    let locationManager = CLLocationManager()
    var LocationArray:[Location] = []
    var currentLocation:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(120.665441), Double(31.2043183));
    let dropDown = DropDown()
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
        
//        central.delegate = self
//        central.addAvailabilityObserver(self)
//        do {
//            let serviceUUID = UUID(uuidString: "0000ffe1-0000-1000-8000-00805f9b34fb")!
//            let characteristicUUID = UUID(uuidString: "0000ffe1-0000-1000-8000-00805f9b34fb")!
//            let configuration = BKConfiguration(dataServiceUUID: serviceUUID , dataServiceCharacteristicUUID: characteristicUUID )
//            try central.startWithConfiguration(configuration)
//            // Once the availability observer has been positively notified, you're ready to discover and connect to peripherals.
//
//
//        } catch let error {
//            // Handle error.
//        }
        
        
//        peripheral.delegate = self
//        do {
//            let serviceUUID = NSUUID(uuidString: "0000ffe1-0000-1000-8000-00805f9b34fb")!
//            let characteristicUUID = NSUUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
//            let localName = "DEVICE_NAME"
//            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID as UUID, dataServiceCharacteristicUUID:     characteristicUUID as UUID, localName: localName)
//            try peripheral.startWithConfiguration(configuration)
//            // You are now ready for incoming connections
//        } catch let error {
//            // Handle error.
//        }

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
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print(peripheral.name)
            
            if peripheral.name!.range(of:"iODS775") != nil{
                self.peripheral=peripheral
                self.peripheral.delegate=self
                manager.connect(peripheral, options: nil)
            }
        }
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
    private func scan() {
//        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
//            // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
//            // Handle current "available" discoveries, [BKDiscovery].
//            // This is where you'd ie. update a table view.
//
//        }, stateHandler: { newState in
//            // Handle newState, BKCentral.ContinuousScanState.
//            // This is where you'd ie. start/stop an activity indicator.
//            if newState == .scanning {
//
//
//            } else if newState == .stopped {
//
//
//            }
//        }, duration: 3, inBetweenDelay: 3, errorHandler: { error in
//            // Handle error.
//        })
    }
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
            Socket.openLock(longitude: String(format:"%f",(self?.currentLocation.longitude)!),latutude: String(format:"%f",(self?.currentLocation.latitude)!),lockId: (self?.LocationArray[index].id)!)
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
            Socket.openLock(lockId: (self?.LocationArray[index].id)!)
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
}
