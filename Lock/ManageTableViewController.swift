//
//  ManageTableViewController.swift
//  Lock
//
//  Created by yong hu on 2018/10/23.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class ManageTableViewController: UITableViewController {
    internal var cellArray:[String] = ["日志查询","网络配置","数据清除","修改密码","使用帮助","当前版本"]
    let strArray:[String]=["日志","网络","数据","修改","使用帮助","火箭"]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title="终端管理"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //self.tableView.register(UINib(nibName: "ManageTableViewCell", bundle: nil), forCellReuseIdentifier: "ManageTableViewCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return cellArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "ManageTableViewCell") as? ManageTableViewCell
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.imageView?.image=UIImage(named: strArray[indexPath.section])
        cell.textLabel?.text = cellArray[indexPath.section]
        cell.accessoryType = .disclosureIndicator;
        
        let itemSize = CGSize.init(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell.imageView?.image!.draw(in: imageRect)
        cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \(indexPath.section) selected")
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "log", sender: nil)
        case 1:
            performSegue(withIdentifier: "server", sender: nil)
        case 2:
            performSegue(withIdentifier: "clear", sender: nil)
        case 3:
            performSegue(withIdentifier: "password", sender: nil)
        case 4:
            performSegue(withIdentifier: "help", sender: nil)
        default:
            performSegue(withIdentifier: "version", sender: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
