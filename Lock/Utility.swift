//
//  Utility.swift
//  Lock
//
//  Created by yong hu on 12/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

class Utility: NSObject {
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    class func copyFile(fileName: NSString) {
        
        let dbPath: String = getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            
            
            let fromPath = Bundle.main.url(forResource: "db", withExtension: "sqlite")
            
            do {
                try fileManager.copyItem(atPath: fromPath!.path, toPath: dbPath)
            } catch _ as NSError {
                
            }
            
        }
        
    }
}
