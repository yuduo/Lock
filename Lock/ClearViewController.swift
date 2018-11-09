//
//  ClearViewController.swift
//  Lock
//
//  Created by yong hu on 2018/10/23.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import DropDown
class ClearViewController: UIViewController {
    @IBOutlet weak var ticket: UILabel!
    @IBOutlet weak var log: UILabel!
    
    @IBOutlet weak var drop: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var OKButton: UIButton!
    let dropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="数据清理"
        // Do any additional setup after loading the view.
        OKButton.layer.cornerRadius=5
        CancelButton.layer.cornerRadius=5
        drop.layer.borderWidth=1
        drop.layer.borderColor = UIColor.blue.cgColor
        drop.layer.cornerRadius = 5
        
        dropDown.anchorView = drop // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: drop.bounds.height)
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["一个月","三个月","全部"]
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.drop.setTitle(item, for: .normal)
        }
        dropDown.selectRow(at: 0)
        self.drop.setTitle("一个月", for: .normal)
        log.text=String(Log.opCount())
    }
    
    @IBAction func dropClicked(_ sender: Any) {
        dropDown.show()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func OK(_ sender: Any) {
        Log.clear("1")
    }
    
    @IBAction func Cancel(_ sender: Any) {
    }
}
