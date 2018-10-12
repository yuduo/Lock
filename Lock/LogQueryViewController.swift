//
//  LogQueryViewController.swift
//  Lock
//
//  Created by yong hu on 12/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import SQLite
class LogQueryViewController: UIViewController {
    var logArray:[Operation] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func queryButtonClicked(_ sender: Any) {
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("operation")
        let User_Account = Expression<String?>("User_Account")
        let Date_Time = Expression<String?>("Date_Time")
        let Operation_Record = Expression<String>("Operation_Record")
        let insert = ops.insert(User_Account <- "Alice", Date_Time <- "alice@mac.com", Operation_Record <- "alice@mac.com")
        let rowid = try? db?.run(insert)
        
        
        for ope in (try! db?.prepare(ops))! {
            print("id: \(ope[Operation_Record]), name: \(ope[User_Account]), email: \(ope[Date_Time])")
            
            var op:Operation!
            op.User_Account=ope[User_Account]!
            op.Date_Time=ope[Date_Time]!
            op.Operation_Record=ope[Operation_Record]
            logArray.append(op)
        }
        
        //let alice = users.filter(id == rowid)//查询
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLogTableSegue"
        {
            if let destinationVC = segue.destination as? LogTableViewController {
                destinationVC.logArray = logArray
            }
        }
    }
}
