//
//  SQLiteDatabaseObjectAdder.swift
//  SwiftyDB
//
//  Created by Øyvind Grimnes on 22/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import TinySQLite

struct SQLiteDatabaseInserter: DatabaseInserter {
    
    let databaseQueue: DatabaseQueue
    let queryFactory: SQLiteQueryFactory
    
    init(databaseQueue: DatabaseQueue, queryFactory: SQLiteQueryFactory) {
        self.databaseQueue = databaseQueue
        self.queryFactory = queryFactory
    }
    
    func add(readers: [Reader]) throws {
        guard readers.count > 0 else {
            return
        }
        
        let mappedReaders = readers.group { String(describing: $0.type) }
        
        try databaseQueue.transaction { database in
            for (_, readers) in mappedReaders {
                let query      = self.queryFactory.insertQuery(for: readers.first!)
                
                let statement = try database.statement(for: query.query)
                
                defer {
                    try! statement.finalize()
                }
                
                for reader in readers {
                    var parameters: [String: SQLiteValue?] = [:]
                    
                    for (key, value) in reader.storableValues {
                        parameters[key] = value as? SQLiteValue
                    }
                    
                    _ = try statement.executeUpdate(withParameterMapping: parameters)
                }
            }
        }
    }
}
