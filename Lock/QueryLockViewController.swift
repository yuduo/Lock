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
class QueryLockViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating {
    
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableview: UITableView!
    var LockArray:[Lock] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.delegate=self
        tableview.dataSource=self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        tableview.tableHeaderView = searchController.searchBar
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        queryAll()
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
    func updateSearchResults(for searchController: UISearchController) {
        self.tableview.reloadData()
    }
    func queryAll(){
        var message:[UInt8]=[]
        for _ in 1...50{
            message.append(0x00)
        }
        let type:[UInt8]=[0x00]//lock name
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
                        let error = MessageView.viewFromNib(layout: .tabView)
                        error.configureTheme(.error)
                        error.configureContent(title: "Error", body: "Something is horribly wrong!")
                        error.button?.setTitle("Stop", for: .normal)
                        
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
}
