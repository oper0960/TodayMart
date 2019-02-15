//
//  SQLiteManager.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 21..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import SQLite3

typealias MartTuple = (String, [Int], [Int], Int, String, [Int])

class SQLiteManager {
    
    enum SQLError: Error {
        case connectionError
        case queryError
        case otherError
    }
    
    var db: OpaquePointer?
    var stmt: OpaquePointer?
    
    private let dbPath: String = {
        let bundleURL = Bundle.main.url(forResource: "ClosedDatabase", withExtension: "db")
        let fileManager = FileManager.default
        let dbName = "ClosedDatabase.db"
        
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent("DB")
            
            if !fileManager.fileExists(atPath: "\(fileURL.path)/\(dbName)") {
                do {
                    try fileManager.createDirectory(atPath: fileURL.path, withIntermediateDirectories: true, attributes: nil)
                    let targetURL = fileURL.appendingPathComponent(dbName, isDirectory: false)
                    try fileManager.copyItem(at: bundleURL!, to: targetURL)
                    return "\(fileURL.path)/\(dbName)"
                } catch {
                    return bundleURL?.path
                }
            } else {
                do {
                    let fileDic = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                    return "\(fileURL.path)/\(dbName)"
                } catch {
                    return bundleURL?.path
                }
            }
        } else {
            return bundleURL?.path
        }
    }()!
    
    init() throws {
        // DB Open
        guard sqlite3_open(dbPath, &self.db) == SQLITE_OK else { throw SQLError.connectionError }
    }
    
    deinit {
        // DB Close
        sqlite3_finalize(stmt)
        sqlite3_close(db)
    }
    
    func execute(name: String, rowHandler: ((MartTuple) -> Void)? = nil) throws {
        if sqlite3_prepare_v2(db, "SELECT * FROM Mart WHERE Name = '\(name)';", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while true {
            switch sqlite3_step(stmt) {
            case SQLITE_DONE:
                return
            case SQLITE_ROW:
                // 0 = Name, 1 = ClosedWeek, 2 = ClosedDay, 3 = Favorite, 4 = OpeningHours, 5 = FixedClosedDay
                let name = String(cString: sqlite3_column_text(stmt, 0))
                let closedWeek = splitWeekDay(closedWeek: String(cString: sqlite3_column_text(stmt, 1)))
                let closedDay = splitWeekDay(closedWeek: String(cString: sqlite3_column_text(stmt, 2)))
                let favorite = Int(sqlite3_column_int(stmt, 3))
                let openingHours = String(cString: sqlite3_column_text(stmt, 4))
                var fixedClosedDay: [Int] = []
                if let fixedClosed = sqlite3_column_text(stmt, 5) {
                    fixedClosedDay = splitWeekDay(closedWeek: String(cString: fixedClosed))
                }
                rowHandler!((name, closedWeek, closedDay, favorite, openingHours, fixedClosedDay))
            default:
                throw SQLError.otherError
            }
        }
    }
    
    func executeAll(rowHandler: (([Mart]) -> Void)? = nil) throws {
        if sqlite3_prepare_v2(db, "SELECT * FROM Mart;", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while true {
            switch sqlite3_step(stmt) {
            case SQLITE_DONE:
                return
            case SQLITE_ROW:
                // 0 = Name, 1 = ClosedWeek, 2 = ClosedDay, 3 = Favorite, 4 = OpeningHours
                // 5 = FixClosedDay, 6 = address, 7 = telnumber, 8 = longitude, 9 = latitude
                let name = String(cString: sqlite3_column_text(stmt, 0))
                let closedWeek = splitWeekDay(closedWeek: String(cString: sqlite3_column_text(stmt, 1)))
                let closedDay = splitWeekDay(closedWeek: String(cString: sqlite3_column_text(stmt, 2)))
                let favorite = Int(sqlite3_column_int(stmt, 3))
                let openingHours = String(cString: sqlite3_column_text(stmt, 4))
                var fixedClosedDay: [Int] = []
                if let fixedClosed = sqlite3_column_text(stmt, 5) {
                    fixedClosedDay = splitWeekDay(closedWeek: String(cString: fixedClosed))
                }
                let address = String(cString: sqlite3_column_text(stmt, 6))
                let telNumber = String(cString: sqlite3_column_text(stmt, 7))
                let longitude = String(cString: sqlite3_column_text(stmt, 8))
                let latitude = String(cString: sqlite3_column_text(stmt, 9))
                
                var result = [Mart]()
                result.append(Mart(name: name, week: closedWeek, day: closedDay, fav: favorite,
                                   hours: openingHours, fix: fixedClosedDay, add: address, tel: telNumber,
                                   logi: longitude, lati: latitude))
               
                rowHandler!(result)
            default:
                throw SQLError.otherError
            }
        }
    }
    
    func favoriteExecute(name: String, favorite: Int, doneHandler: (() -> ())? = nil) throws {
        if sqlite3_prepare_v2(db, "UPDATE Mart SET Favorite = \(favorite) WHERE Name = '\(name)';", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        switch sqlite3_step(stmt) {
        case SQLITE_DONE:
            doneHandler!()
            return
        default:
            throw SQLError.otherError
        }
    }
    
    func getFavoriteExecute(rowHandler: ((MartTuple) -> Void)? = nil) throws {
        if sqlite3_prepare_v2(db, "SELECT * FROM Mart WHERE Favorite = 1;", -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while true {
            switch sqlite3_step(stmt) {
            case SQLITE_DONE:
                return
            case SQLITE_ROW:
                // 0 = Name, 1 = ClosedWeek, 2 = ClosedDay, 3 = Favorite, 4 = OpeningHours, 5 = FixedClosedDay
                let name = String(cString: sqlite3_column_text(stmt, 0))
                let closedWeek = splitWeekDay(closedWeek: String(cString: sqlite3_column_text(stmt, 1)))
                let closedDay = splitWeekDay(closedWeek: String(cString: sqlite3_column_text(stmt, 2)))
                let favorite = Int(sqlite3_column_int(stmt, 3))
                let openingHours = String(cString: sqlite3_column_text(stmt, 4))
                var fixedClosedDay: [Int] = []
                if let fixedClosed = sqlite3_column_text(stmt, 5) {
                    fixedClosedDay = splitWeekDay(closedWeek: String(cString: fixedClosed))
                }
                rowHandler!((name, closedWeek, closedDay, favorite, openingHours, fixedClosedDay))
            default:
                throw SQLError.otherError
            }
        }
    }
    
    func splitWeekDay(closedWeek: String) -> closedWeek {
    
        var week = [Int]()
        _ = closedWeek.components(separatedBy: ",").map {
            week.append(Int($0) ?? 0)
        }
        return week
    }
}
