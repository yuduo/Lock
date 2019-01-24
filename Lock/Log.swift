//
//  Log.swift
//  Lock
//
//  Created by yong hu on 19/10/2018.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit
import SQLite
class Log: NSObject {
    class func login(_ user:String,_ record:String){
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("operation")
        let User_Account = Expression<String?>("User_Account")
        let Date_Time = Expression<Date>("Date_Time")
        let Operation_Record = Expression<String>("Operation_Record")
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = gDateFormat
        let date = Date()
        //let dateString = dateFormatter.string(from: date)
        let insert = ops.insert(User_Account <- user, Date_Time <- date.toLocalTime(), Operation_Record <- record)
        let rowid = try? db?.run(insert)
        
    }
    class func opCount()->Int{
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("operation")
        let count = try? db?.scalar(ops.count)
        return count as! Int
    }
    class func clear(_ type:String){
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("operation")
        
        let Date_Time = Expression<Date>("Date_Time")
        switch type {
        case "1"://all
            try? db?.run(ops.delete())
            break
        case "2"://one month
        
            let endDate = Date().toLocalTime()
            let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)?.toLocalTime()
            let query=ops.filter(startDate!...endDate ~= Date_Time)
            try? db?.run(query.delete())
        
            break
        case "3":
            let endDate = Date().toLocalTime()
            let startDate = Calendar.current.date(byAdding: .day, value: -60, to: endDate)?.toLocalTime()
            let query=ops.filter(startDate!...endDate ~= Date_Time)
            try? db?.run(query.delete())
            
            break
        default:
            try? db?.run(ops.delete())
        }
        
    }
    class func getLog()->[Operation]{
        var logArray:[Operation] = []
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("operation")
        let User_Account = Expression<String>("User_Account")
        let Date_Time = Expression<String>("Date_Time")
        let Operation_Record = Expression<String>("Operation_Record")
        
        
        for ope in (try! db?.prepare(ops))! {
            if ope[Operation_Record].isEmpty{
                continue
            }
            print("id: \(ope[Operation_Record]), name: \(ope[User_Account]), email: \(ope[Date_Time])")
            
            var op:Operation=Operation()
            op.User_Account=ope[User_Account]
            op.Date_Time=ope[Date_Time]
            op.Operation_Record=ope[Operation_Record]
            logArray.append(op)
        }
        return logArray
    }
    class func getLog(_ start:String,_ end:String)->[Operation]{
        var logArray:[Operation] = []
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("operation")
        let User_Account = Expression<String>("User_Account")
        let Date_Time = Expression<Date>("Date_Time")
        let Date_str = Expression<String>("Date_Time")
        let Operation_Record = Expression<String>("Operation_Record")
        let dateFormatter : DateFormatter = DateFormatter()
        
        //dateFormatter.locale=Locale(identifier:"Asia/Shanghai")
        //dateFormatter.timeZone=TimeZone(identifier:"Asia/Shanghai")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate=dateFormatter.date(from: start)
        let endDate=dateFormatter.date(from: end)

        if(startDate?.compare(endDate!)==ComparisonResult.orderedDescending)
        {
            return logArray
        }
        let query=ops.filter(startDate!.toLocalTime()...endDate!.toLocalTime() ~= Date_Time)
        for ope in (try! db?.prepare(query))! {
            if ope[Operation_Record].isEmpty{
                continue
            }
            //print("id: \(ope[Operation_Record]), name: \(ope[User_Account]), email: \(ope[Date_Time])")
            
            var op:Operation=Operation()
            op.User_Account=ope[User_Account]
            op.Date_Time=ope[Date_str]
            op.Operation_Record=ope[Operation_Record]
            logArray.append(op)
        }
        return logArray
    }
    class func getLog(_ name:String)->[Operation]{
        var logArray:[Operation] = []
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("operation")
        let User_Account = Expression<String>("User_Account")
        let Date_Time = Expression<String>("Date_Time")
        let Operation_Record = Expression<String>("Operation_Record")
        
        let query=ops.filter(name == User_Account)
        for ope in (try! db?.prepare(query))! {
            if ope[Operation_Record].isEmpty{
                continue
            }
            print("id: \(ope[Operation_Record]), name: \(ope[User_Account]), email: \(ope[Date_Time])")
            
            var op:Operation=Operation()
            op.User_Account=ope[User_Account]
            op.Date_Time=ope[Date_Time]
            op.Operation_Record=ope[Operation_Record]
            logArray.append(op)
        }
        return logArray
    }
    class func getLock(lock:String,UserIDs:String)->Bool{
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("lock")
        let UserID = Expression<String?>("UserID")
        let Locker_ID = Expression<String?>("Locker_ID")
        var ls = lock.replacingOccurrences(of: "\u{f}", with: "", options: NSString.CompareOptions.literal, range: nil)
        ls = ls.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: nil)
        let count = try? db!.scalar(ops.filter(UserID==UserIDs&&Locker_ID==ls).count)
        if count! > 0{
            return true
        }
        return false
    }
    class func lock(locks:String,UserIDs:String){
        if locks.count == 0{
            return
        }
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("lock")
        let UserID = Expression<String?>("UserID")
        let Locker_ID = Expression<String?>("Locker_ID")
        var ls = locks.replacingOccurrences(of: "\u{f}", with: "", options: NSString.CompareOptions.literal, range: nil)
        ls = ls.replacingOccurrences(of: "\u{0f}", with: "", options: NSString.CompareOptions.literal, range: nil)
        ls = ls.replacingOccurrences(of: "\u{0F}", with: "", options: NSString.CompareOptions.literal, range: nil)
        ls = ls.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let lockers=ls.components(separatedBy: "\r")
        try? db?.run(ops.delete())
        for lock in lockers{
            try? db?.run(ops.insert(or: .replace, UserID <- UserIDs, Locker_ID <- lock))
        }
    }
    class func User(user:User){
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("user")
        let UserID = Expression<String?>("UserID")
        let UserType = Expression<String?>("UserType")
        let UserPassWd = Expression<String?>("UserPassWd")
        let Flash_Date = Expression<String?>("Flash_Date")
        let Last_Tag = Expression<Int?>("Last_Tag")
        //try? db?.run(ops.insert(or: .replace, UserID <- user.UserID, UserType <- user.UserType, UserPassWd <- user.UserPassWd,Flash_Date <- user.Flash_Date,Last_Tag <- user.Last_Tag))
        try? db?.run(ops.insert(UserID <- user.UserID, UserType <- user.UserType, UserPassWd <- user.UserPassWd,Flash_Date <- user.Flash_Date,Last_Tag <- user.Last_Tag))
    }
    class func DeleteUser(_ username:String)
    {
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("user")
        let UserID = Expression<String?>("UserID")
        
        let query=ops.filter(UserID==username)
        try? db?.run(query.delete())
    }
    class func User(username:String,password:String)->Bool{
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("user")
        let UserID = Expression<String?>("UserID")
        
        let UserPassWd = Expression<String?>("UserPassWd")
        let count = try? db!.scalar(ops.filter(UserID==username&&password==UserPassWd).count)
        if count! > 0{
            return true
        }
        return false;
    }
    class func User()->String{
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let users = Table("user")
        let UserID = Expression<String?>("UserID")
        let id = Expression<Int?>("id")
        let query = users.select(UserID)           // SELECT "email" FROM "users"
            .order(id.desc) // ORDER BY "email" DESC, "name"
            .limit(5)     // LIMIT 5 OFFSET 1
        for user in try! (db?.prepare(query))! {
            return user[UserID] ?? ""
        }
        
        return ""
    }
    class func server(_ adress:String,_ port:String,_ scope:Int){
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let ops = Table("setting")
        let NMSAdrres = Expression<String?>("NMSAdrres")
        let NMSPort = Expression<String?>("NMSPort")
        let Search_Scope = Expression<Int>("Search_Scope")
        try? db?.run(ops.insert(or: .replace, NMSAdrres <- adress, NMSPort <- port,Search_Scope <- scope))

    }
    class func servers()->Server{
        let dbPath: String = Utility.getDocumentsDirectory().appendingPathComponent("db.sqlite").path
        print(dbPath)
        let db = try? Connection(dbPath)
        
        let settings = Table("setting")
        let NMSAdrres = Expression<String>("NMSAdrres")
        let NMSPort = Expression<Int>("NMSPort")
        let Search_Scope = Expression<Int>("Search_Scope")
        var server:Server=Server()
        for setting in try! (db?.prepare(settings))! {
            
            server.NMSAdrres=setting[NMSAdrres]
            server.NMSPort=String(setting[NMSPort])
            server.Search_Scope=String(setting[Search_Scope])
        }
        return server
    }
}
