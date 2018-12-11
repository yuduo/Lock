//
//  QueryLockViewController.swift
//  Lock
//
//  Created by yong hu on 15/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftSocket
import SwiftMessages
import DLRadioButton
class QueryLockViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating ,UISearchBarDelegate{
    var location:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(31.2043183),Double(120.665441) );
    @IBOutlet weak var nameButton: DLRadioButton!
    
    @IBOutlet weak var codeButton: DLRadioButton!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var LockArray:[Lock] = []
    
    var selected:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title="锁具查询"
        // Do any additional setup after loading the view.
        tableview.delegate=self
        tableview.dataSource=self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        //tableview.tableHeaderView = searchController.searchBar
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
       
        nameButton.isSelected=true
        codeButton.isSelected=false
        
        searchBar.delegate=self
        nameButton.addTarget(self, action: #selector(QueryLockViewController.logSelectedButton), for: UIControlEvents.touchUpInside);
        codeButton.addTarget(self, action: #selector(QueryLockViewController.logSelectedButton), for: UIControlEvents.touchUpInside);
        queryAll(str: "")
    }

    @objc @IBAction private func logSelectedButton(radioButton : DLRadioButton) {
        queryAll(str: "")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(searchText)
        //queryAll(str: searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        queryAll(str: searchBar.text!)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return LockArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text=LockArray[indexPath.row].name
        return cell
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "", message: "导航到锁设备位置？", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "导航", style: .default) { (action:UIAlertAction!) in
            
            if self.LockArray.count > indexPath.row{
                let lock:Lock=self.LockArray[indexPath.row]
                self.location.latitude=Double(lock.latutude)!
                self.location.longitude=Double(lock.longitude)!
                self.selected=indexPath.row
                self.performSegue(withIdentifier: "location", sender: nil)
            }
            
        }
        alert.addAction(OKAction)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        self.tableview.reloadData()
    }
    private func sendLockNext(byte:UInt8)->Data{
        let message:[UInt8]=[byte]
        let m:[UInt8]=[0x00,0x10, 0x01,0x00,0x01,0x00,0x02,0x62,0x6c]+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x01,0x00,0x01,0x00,0x02,0x62,0x6c]+message+byteArray+[0x7e])
        return data
    }
    private func queryAll(str:String){
        var message:[UInt8]=[]
        if (str.count > 0){
            message = Array(str.utf8)
        }
        
        for _ in message.count..<50{
            message.append(0x00)
        }
        var type:[UInt8]=[]
        if nameButton.isSelected{
            type=[0x00]
        }else{
            type=[0xff]
        }
        let m:[UInt8]=[0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0f,0x62,0xff]+type+message
        
        var crc=m.crc16()
        
        let bytePtr = withUnsafePointer(to: &crc) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 2) {
                UnsafeBufferPointer(start: $0, count: 2)
            }
        }
        let byteArray = Array(bytePtr)
        let data = Data(bytes: [0x7e, 0x00,0x10, 0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0f,0x62,0xff]+type+message+byteArray+[0x7e])
        
        
        
//        switch client.connect(timeout: 10) {
//        case .success:
            switch client.send(data:data ) {
            case .success:
                sleep(1)
                var rdata:[Byte]=[]
                var i:Int=0
                while true{
                    guard let r = client.read(1024*10) else { break }
                    if (r[3] != r[5]){
                        print(r[3])
                        print(r[5])
                        if i == 0 {
                            rdata+=r[0...r.count-4]
                        }else{
                            rdata+=r[20...r.count-4]
                        }
                        i+=1
                        //client.send(data:data )
                    }else{
                        rdata+=r
                        break
                    }
                }
                if rdata.count == 0{
                    return
                }
                
                if rdata[0] == 0x7e
                {
                    
                    let response=Array(rdata[20...rdata.count-1])
                    if response[0] == 0x00{
                        //faild
                        loadFaild("未查询到！")
                    }else {
                        loadSuccess()
                        print(response.count)
                        
                        let size=response[0]
                        var locks=(rdata[21...rdata.count-1])
                        var ind=locks.firstIndex(of:0x7E)

                        if ind == nil || ind! >= locks.count{
                            
                        }else{
                            var rang=ind!-2...ind!+20
                            locks.removeSubrange(rang)
                            ind=locks.firstIndex(of:0x7E)
                            rang=ind!-2...ind!+20
                            locks.removeSubrange(rang)
                            ind=locks.firstIndex(of:0x7E)
                            rang=ind!-2...ind!+20
                            locks.removeSubrange(rang)
                        }
                        

                        
                        LockArray.removeAll()
                        //let count:Int=Int((size+1)*70+1)
                       // if  count==response.count{
                        var s:Int=0+21
                        var e:Int=9+21
                        for i in 0..<size{
                                var loc:Lock!=Lock()
                                //s=Int(i*70)
                                e=s+9//Int(9+i*70)
                                let lon=(locks[s...e])
                                loc.longitude=String(data: Data(bytes:lon), encoding: String.Encoding.utf8) ?? ""
                            print(s)
                            print(e)
                            print(String(data: Data(bytes:lon), encoding: String.Encoding.utf8))
                                s=e+1//Int(10+i*70)
                                e=s+9//Int(19+i*70)
                                let lan=(locks[s...e])
                                loc.latutude=String(data: Data(bytes:lan), encoding: String.Encoding.utf8) ?? ""
                            print(s)
                            print(e)
                            print(String(data: Data(bytes:lan), encoding: String.Encoding.utf8))
                                s=e+1//Int(20+i*70)
                                e=s+49//Int(69+i*70)
                                let name=(locks[s...e])
                            
                            
                                loc.name=String(data: Data(bytes:name), encoding: String.Encoding.utf8) ?? ""
                            print(s)
                            print(e)
                            print(String(data: Data(bytes:name), encoding: String.Encoding.utf8))
                                self.LockArray.append(loc)
                                s=e+1
                                print(loc.longitude)
                                print(loc.latutude)
                                print(loc.name)
                            
                            
                            }
                           self.tableview.reloadData()
                        //}
                        
                    }
                    
                    
                }
                
            case .failure(let error):
                print(error)
            }
//        case .failure(let error):
//            print(error)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed

        if segue.identifier == "location"
        {
            if let destinationVC = segue.destination as? LocationViewController {
                destinationVC.location = location
                let lock:Lock=self.LockArray[self.selected]
                destinationVC.name=lock.name
            }
        }
    }
}
