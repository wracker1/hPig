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
        if context.hasChanges {
            do {
                try context.save()
            } catch let e {
                print("core data sava error: \(e)")
            }
        }
    }
}
