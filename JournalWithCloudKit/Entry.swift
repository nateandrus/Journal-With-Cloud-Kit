//
//  Entry.swift
//  JournalWithCloudKit
//
//  Created by Nathan Andrus on 2/25/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import Foundation
import CloudKit

class Entry {
    
    static let entryKey = "Entry"
    static let titleKey = "Title"
    static let textKey = "Text"
    
    var title: String
    var text: String
    let CKRecordID: CKRecord.ID
    
    init(title: String, text: String, CKRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.title = title
        self.text = text
        self.CKRecordID = CKRecordID
    }
    
    convenience init?(record: CKRecord) {
        guard let title = record[Entry.titleKey] as? String,
            let text = record[Entry.textKey] as? String else { return nil}
    
        self.init(title: title, text: text, CKRecordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(entry: Entry) {
        self.init(recordType: Entry.entryKey)
        self.setValue(entry.title, forKey: Entry.titleKey)
        self.setValue(entry.text, forKey: Entry.textKey)
    }
}

extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.CKRecordID == rhs.CKRecordID 
    }
}
