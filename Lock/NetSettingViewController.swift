//
//  NetSettingViewController.swift
//  Lock
//
//  Created by yong hu on 2018/10/23.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class NetSettingViewController: UIViewController {
    @IBOutlet weak var OKButton: UIButton!
    var scope:Int=0
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var adress: UITextField!
    @IBOutlet weak var port: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        OKButton.layer.cornerRadius=5
        CancelButton.layer.cornerRadius=5
        slider.minimumValue=1
        slider.maximumValue=10
        self.title="网络配置"
        let server=Log.servers()
        adress.text=server.NMSAdrres
        port.text=server.NMSPort
        slider.value=Float(server.Search_Scope) ?? 1
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        scope=Int(sender.value)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func OKButtonClicked(_ sender: Any) {
        
        
        if (adress.text?.isEmpty)! || (port.text?.isEmpty)!{
            let alert = UIAlertController(title: "Alert", message: "不能为空", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
                // Code in this block will trigger when OK button tapped.
                print("Ok button tapped");
                
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        Log.server(adress.text!, port.text!, String(scope))
    }
}
