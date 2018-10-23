//
//  LogQueryViewController.swift
//  Lock
//
//  Created by yong hu on 12/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import SQLite
import DropDown
class LogQueryViewController: UIViewController {
    var logArray:[Operation] = []
        @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var chooseView: UIView!
    
    @IBOutlet weak var queryButton: UIButton!
    @IBOutlet weak var dropButton: UIButton!
    let dropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dropButton.isHidden=true;
        // Do any additional setup after loading the view.
        // The view to which the drop down will appear on
        dropDown.anchorView = dropButton // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: dropButton.bounds.height)
        
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.dropButton.setTitle(item, for: .normal)
        }
        chooseView.isHidden=false
        dropDown.hide()
        
        dropButton.layer.borderWidth=1
        dropButton.layer.borderColor = UIColor.blue.cgColor
        dropButton.layer.cornerRadius = 5
        queryButton.layer.cornerRadius = 5
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
            if ope[Operation_Record].isEmpty{
                continue
            }
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
    @IBAction func dropButtonClicked(_ sender: Any) {
        dropDown.show()
    }
    
    
    @IBAction func didSelect(_ sender: Any) {
        if(segment.selectedSegmentIndex == 0)
        {
            chooseView.isHidden=false
            dropButton.isHidden=true
            dropDown.hide()
        }
        else if(segment.selectedSegmentIndex == 1)
        {
            chooseView.isHidden=true
            dropButton.isHidden=false
            
        }
    }
}
