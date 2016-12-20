//
//  CoreDataService.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 2..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import CoreData

enum CoreDataServiceError : Error {
    case entityNotFoundError
}

class CoreDataService {
    static let shared: CoreDataService = {
        let instance = CoreDataService()
        return instance
    }()
    
    let appDelegate: AppDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    let context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    func entityDescription(_ entityName: String) -> (NSEntityDescription?, NSManagedObjectContext) {
        return (description: NSEntityDescription.entity(forEntityName: entityName.uppercased(), in: context), context: context)
    }
    
    func select<T>(request: NSFetchRequest<T>, resultBlock: @escaping ([T], Error?) -> Void) {
        context.perform {
            do {
                let result = try request.execute()
                resultBlock(result, nil)
            } catch let e {
                resultBlock([], e)
            }
        }
    }
    
    func delete<T>(model: T) {
        context.delete(model as! NSManagedObject)
    }
    
    func save() {
        self.appDelegate.saveContext()
    }
    
    func deleteUserData(_ userId: String?, itemIds: [String] = [String]()) {
        let id = userId ?? kGuestId
        
        if itemIds.isEmpty {
            deleteTimeLog(id)
            deleteWord(id)
            deleteHistory(id)
            deletePattern(id)
        } else {
            itemIds.forEach { (itemId) in
                switch itemId {
                case "delTimelog":
                    deleteTimeLog(id)
                    
                case "delWord":
                    deleteWord(id)
                    
                case "delHistory":
                    deleteHistory(id)
                    
                case "delPattern":
                    deletePattern(id)
                    
                default:
                    print(itemId)
                }
            }
        }
    }
    
    private func deleteTimeLog(_ id: String) {
        let timeReq: NSFetchRequest<TIME_LOG> = TIME_LOG.fetchRequest()
        timeReq.predicate = NSPredicate(format: "uid = '\(id)'")
        easeDelete(timeReq)
    }
    
    private func deleteWord(_ id: String) {
        let wordReq: NSFetchRequest<WORD> = WORD.fetchRequest()
        wordReq.predicate = NSPredicate(format: "uid = '\(id)'")
        easeDelete(wordReq)
    }
    
    private func deleteHistory(_ id: String) {
        let historyReq: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
        historyReq.predicate = NSPredicate(format: "uid = '\(id)'")
        easeDelete(historyReq)
    }
    
    private func deletePattern(_ id: String) {
        let patternReq: NSFetchRequest<PATTERN> = PATTERN.fetchRequest()
        patternReq.predicate = NSPredicate(format: "uid = '\(id)'")
        easeDelete(patternReq)
    }
    
    private func easeDelete<T>(_ req: NSFetchRequest<T>) {
        select(request: req) { (items, _) in
            items.forEach({ (item) in
                self.delete(model: item)
                self.save()
            })
        }
    }

}
