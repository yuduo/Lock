//
//  FeedbackViewController.swift
//  Lock
//
//  Created by yong hu on 2018/10/23.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
class FeedbackViewController: UIViewController {

    @IBOutlet weak var content: KMPlaceholderTextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        content.placeholder="请简单描述一下，您在使用本软件过程中遇到的问题，方便我们后期的修正与改进，谢谢~"
        self.title="使用帮助"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func OKClicked(_ sender: Any) {
    }
}
