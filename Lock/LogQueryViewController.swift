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
    
    @IBOutlet weak var downView: UIImageView!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var queryButton: UIButton!
    @IBOutlet weak var dropButton: UIButton!
    let dropDown = DropDown()
    var type:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title="日志查询"
        logArray=Log.getLog()
        // Do any additional setup after loading the view.
        dropButton.isHidden=true;
        // Do any additional setup after loading the view.
        // The view to which the drop down will appear on
        dropDown.anchorView = dropButton // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: dropButton.bounds.height)
        
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = getUsers()
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.dropButton.setTitle(item, for: .normal)
        }
        chooseView.isHidden=false
        dropDown.hide()
        downView.isHidden=true
        dropButton.layer.borderWidth=1
        dropButton.layer.borderColor = UIColor.blue.cgColor
        dropButton.layer.cornerRadius = 5
        queryButton.layer.cornerRadius = 5
        
        picker.datePickerMode=UIDatePickerMode.date
        picker.isHidden=true
        
        let Tap = UITapGestureRecognizer(target: self, action: #selector(LogQueryViewController.Tap))
        let sTap = UITapGestureRecognizer(target: self, action: #selector(LogQueryViewController.startTap))
        let eTap = UITapGestureRecognizer(target: self, action: #selector(LogQueryViewController.endTap))
        startLabel.isUserInteractionEnabled = true
        startLabel.addGestureRecognizer(sTap)
        
        endLabel.isUserInteractionEnabled = true
        endLabel.addGestureRecognizer(eTap)
        self.view.addGestureRecognizer(Tap)
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        startLabel.text=dateString
        endLabel.text=dateString
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func Tap(sender:UITapGestureRecognizer) {
        
        picker.isHidden=true
        
        type=0
        
    }
    @objc func startTap(sender:UITapGestureRecognizer) {
        
        picker.isHidden=false
        
        type=1
        
    }
    @objc func endTap(sender:UITapGestureRecognizer) {
        
        picker.isHidden=false
        
        type=2
        
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
        
        performSegue(withIdentifier: "logList", sender: nil)
        //let alice = users.filter(id == rowid)//查询
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logList"
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
            downView.isHidden=true
        }
        else if(segment.selectedSegmentIndex == 1)
        {
            chooseView.isHidden=true
            dropButton.isHidden=false
            downView.isHidden=false
        }
    }
    @IBAction func pickerAction(_ sender: Any) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let strDate = dateFormatter.string(from: picker.date)
        if type==1{
            self.startLabel.text = strDate
        }else{
            self.endLabel.text = strDate
        }
        
    }
    
    func getUsers()->[String]{
        var list:[String]=[]
        for operation in logArray{
            list.append(operation.User_Account)
        }
        return list
    }
    
}
