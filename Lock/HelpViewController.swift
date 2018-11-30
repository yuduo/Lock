//
//  HelpViewController.swift
//  Lock
//
//  Created by yong hu on 2018/10/23.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var quitButton: UIButton!
    let rowArray=["使用与帮助",
                  //"反馈信息",
                  "版本更新"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="使用帮助"
        // Do any additional setup after loading the view.
        quitButton.layer.cornerRadius=5
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableview.delegate=self
        self.tableview.dataSource=self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func quitButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell     {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = rowArray[indexPath.row]
        cell.accessoryType = .disclosureIndicator;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \(indexPath.row) selected")
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "about", sender: nil)
        case 1:
//            performSegue(withIdentifier: "feedback", sender: nil)
//        case 2:
            //
            let url=URL(string: "https://itunes.apple.com/id382165332")
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        
        default:
            performSegue(withIdentifier: "feedback", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}
