//
//  LogTableViewCell.swift
//  Lock
//
//  Created by yong hu on 12/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var opeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func load(operation:Operation){
        timeLabel.text=operation.Date_Time
        targetLabel.text=operation.User_Account
        opeLabel.text=operation.Operation_Record
    }
}
