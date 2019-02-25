//
//  EntryController.swift
//  JournalWithCloudKit
//
//  Created by Nathan Andrus on 2/25/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    //Singleton
    static let shared = EntryController()
    
    static let publicDB = CKContainer.default().publicCloudDatabase
    
    //Source of Truth
    var entries: [Entry] = []
    
    //CRUD functions
    func save(entry: Entry, completion: @escaping (Bool) -> Void) {

        let recordToSave = CKRecord(entry: entry)
        EntryController.publicDB.save(recordToSave) { (record, error) in
            if let error = error {
                print("Error saving record to iCloud: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let record = record,
                let entry = Entry(record: record) else { completion(false); return }
            self.entries.append(entry)
            completion(true)
        }
    }
    
    func addEntryWith(title: String, text: String, completion: @escaping (Bool) -> Void) {
        let entry = Entry(title: title, text: text)
        self.save(entry: entry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func fetchEntries(completion: @escaping(Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Entry.entryKey, predicate: predicate)
        EntryController.publicDB.perform(query, inZoneWith: nil) { (entries, error) in
            if let error = error {
                print("There was an error fetching entries from cloud: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let fetchedEntries = entries else { completion(false); return }
            let newEntries = fetchedEntries.compactMap({ Entry(record: $0)})
            self.entries = newEntries
            completion(true)
        }
        
    }
    
    func update(entry: Entry, title: String, text: String, completion: @escaping (Bool) -> Void) {
        
        entry.title = title
        entry.text = text
        
        EntryController.publicDB.fetch(withRecordID: entry.CKRecordID) { (record, error) in
            if let error = error {
                print("Error updating. \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let record = record else { completion(false); return }
            record[Entry.titleKey] = title
            record[Entry.textKey] = text
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIDs, error ) in
                completion(true)
            }
            EntryController.publicDB.add(operation)
        }
    }
    
    func delete(entry: Entry, completion: @escaping (Bool) -> Void) {
        
        guard let index = EntryController.shared.entries.index(of: entry) else { return }
        EntryController.shared.entries.remove(at: index)
        
        EntryController.publicDB.delete(withRecordID: entry.CKRecordID) { (record, error) in
            if let error = error {
                print("There was an error deleting entry: \(error.localizedDescription)")
                completion(false)
                return
            } else {
                completion(true)
                print("successfully deleted from icloud")
            }
        }
    }
}
