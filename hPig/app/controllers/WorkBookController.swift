//
//  WorkBookController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData

class WorkBookController: UIViewController {

    @IBOutlet weak var segMenu: UISegmentedControl!
    @IBOutlet weak var patternTableView: UITableView!
    @IBOutlet weak var wordTableView: UITableView!
    
    private var patternData = [PATTERN]()
    private var wordData = [WORD]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toggleTableView()
    }
    
    @IBAction func segValueChanged(_ sender: AnyObject) {
        toggleTableView()
    }
    
    private func toggleTableView() {
        switch segMenu.selectedSegmentIndex {
        case 0:
            loadPatternData {
                self.patternTableView.isHidden = false
                self.wordTableView.isHidden = true
            }
        case 1:
            loadWordData {
                self.patternTableView.isHidden = true
                self.wordTableView.isHidden = false
            }
        default:
            print("error")
        }
    }
    
    private func loadPatternData(completion: (() -> Void)?) {
        let dataService = CoreDataService.shared
        let req: NSFetchRequest<PATTERN> = PATTERN.fetchRequest()
        let userId = AuthenticateService.shared.userId()
        let query = "uid = '\(userId)'"
        req.predicate = NSPredicate(format: query)
        
        dataService.select(request: req) { (items, error) in
            self.patternData = items
            self.patternTableView.reloadData()
            
            print(items)
            
            if let callback = completion {
                callback()
            }
        }
    }
    
    private func loadWordData(completion: (() -> Void)?) {
        let dataService = CoreDataService.shared
        let req: NSFetchRequest<WORD> = WORD.fetchRequest()
        let userId = AuthenticateService.shared.userId()
        let query = "uid = '\(userId)'"
        req.predicate = NSPredicate(format: query)
        
        dataService.select(request: req) { (items, error) in
            self.wordData = items
            self.wordTableView.reloadData()
            
            if let callback = completion {
                callback()
            }
        }
    }
}
