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
    var location:CLLocationCoordinate2D=CLLocationCoordinate2DMake(Double(120.665441), Double(31.2043183));
    @IBOutlet weak var nameButton: DLRadioButton!
    
    @IBOutlet weak var codeButton: DLRadioButton!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var LockArray:[Lock] = []
    
    
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
        
        queryAll(str: "")
        nameButton.isSelected=true
        codeButton.isSelected=false
        
        searchBar.delegate=self
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(searchText)
        queryAll(str: searchText)
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
        if LockArray.count > indexPath.row{
            let lock:Lock=LockArray[indexPath.row]
            location.latitude=Double(lock.latutude)!
            location.longitude=Double(lock.longitude)!
            performSegue(withIdentifier: "location", sender: nil)
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        self.tableview.reloadData()
    }
    func queryAll(str:String){
        var message:[UInt8]=[]
        if (str.count > 0){
            message = Array(str.utf8)
        }
        
        for _ in 1...50{
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
                guard let rdata = client.read(1024*10) else { return }
                if rdata[0] == 0x7e
                {
                    
                    let response=Array(rdata[20...rdata.count-3])
                    if response[0] == 0x00{
                        //faild
                        loadFaild()
                    }else {
                        loadSuccess()
                        print(response.count)
                        let size=response[0]
                        let locks=Array(response[1...response.count-1])
                        //let count:Int=Int((size+1)*70+1)
                       // if  count==response.count{
                            for i in 0...size{
                                var lock:Lock!=Lock()
                                let lon=locks[0...9]
                                let lan=locks[10...19]
                                let name=locks[20...69]
                                lock.longitude=String(data: Data(bytes:lon), encoding: String.Encoding.utf8)!
                                lock.latutude=String(data: Data(bytes:lan), encoding: String.Encoding.utf8)!
                                lock.name=String(data: Data(bytes:name), encoding: String.Encoding.utf8)!
                                LockArray.append(lock)
                           // }
                           self.tableview.reloadData()
                        }
                        
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
        if segue.identifier == "location"
        {
            if let destinationVC = segue.destination as? LocationViewController {
                destinationVC.location = location
            }
        }
    }
}
