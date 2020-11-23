//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        self.context.perform {
            guard let coreDataEntries = self.fetchEntriesFromPersistentStore(in: self.context) else {
                for entryRep in entries {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                    
                }
                completion(nil)
                return
        }
        for entryRep in entries {
            guard let identifier = entryRep.identifier else { continue }
            
            let entry = coreDataEntries.first { $0.identifier == identifier }
            if let entry = entry,
                entry != entryRep {
                self.update(entry: entry, with: entryRep)
            } else if entry == nil {
                _ = Entry(entryRepresentation: entryRep, context: self.context)
            }
        }
            print("Syncing completed\(Date())")
            completion(nil)
    }
    }
    
    private func saveToDictionary(entries: [Entry]) -> [String: Entry] {
        var entryDictionary = [String: Entry]()
        for entry in entries {
            entryDictionary[entry.identifier!] = entry
        }
        return entryDictionary
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    private func fetchEntriesFromPersistentStore(in context: NSManagedObjectContext) -> [Entry]? {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        var results: [Entry]? = nil
        do {
            results = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetch entries: \(error)")
        }
        return results
    }
    
    let context: NSManagedObjectContext
}
