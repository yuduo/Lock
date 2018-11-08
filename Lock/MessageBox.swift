//
//  MessageBox.swift
//  Lock
//
//  Created by yong hu on 18/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import SwiftMessages
extension UIViewController {
    func loadSuccess(){
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: "Success", body: "数据更新成功!")
        success.button?.isHidden = true
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .top
        
        SwiftMessages.show(config: successConfig, view: success)
    }
    func loadFaild(){
        let error = MessageView.viewFromNib(layout: .tabView)
        error.configureTheme(.error)
        error.configureContent(title: "Error", body: "数据更新失败!")
        
        
        SwiftMessages.show(view: error)
    }
}
