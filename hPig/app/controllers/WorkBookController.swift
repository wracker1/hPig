//
//  WorkBookController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData

class WorkBookController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segMenu: UISegmentedControl!
    @IBOutlet weak var patternTableView: UITableView!
    @IBOutlet weak var wordTableView: UITableView!
    
    private var patternData = [PATTERN]()
    private var wordData = [WORD]()
    private weak var selectedTableView: UITableView? = nil
    
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
    
    @IBAction func editTableView(_ sender: AnyObject) {
        if let tableView = selectedTableView {
            tableView.setEditing(!tableView.isEditing, animated: true)
        }
    }
    
    @IBAction func returnedFromPatternStudy(segue: UIStoryboardSegue) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == patternTableView {
            return patternData.count
        } else if tableView == wordTableView {
            return wordData.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(tableView), for: indexPath)
        return update(tableView, cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let dataService = CoreDataService.shared
        
        if tableView == patternTableView, let pattern = patternData.get(indexPath.row) {
            patternData.remove(at: indexPath.row)
            dataService.delete(model: pattern)
        }
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        dataService.save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segMenu.selectedSegmentIndex {
        case 0:
            if let cell = patternTableView.cellForRow(at: indexPath), let patternCell = cell as? PatternCell {
                patternCell.toggle()
            }
        case 1:
            print("error")
        default:
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = (segue.destination as! UINavigationController).topViewController
        
        if let patternStudyController = viewController as? PatternStudyController,
            let indexPath = patternTableView.indexPathForSelectedRow,
            let data = patternData.get(indexPath.row),
            let position = data.position,
            let patternIndex = Int(position) {
            
            patternStudyController.id = data.vid
            patternStudyController.part = data.part
            patternStudyController.currentIndex = patternIndex
        }
    }
    
    private func cellId(_ tableView: UITableView) -> String {
        if tableView == patternTableView {
            return "PatternCell"
        } else if tableView == wordTableView {
            return "WordCell"
        } else {
            return "error"
        }
    }
    
    private func update(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        if tableView == patternTableView, let data = patternData.get(indexPath.row), let itemCell = cell as? PatternCell {
            return itemCell.update(data: data)
        } else if tableView == wordTableView {
            return cell
        } else {
            return cell
        }
    }
    
    private func toggleTableView() {
        switch segMenu.selectedSegmentIndex {
        case 0:
            loadPatternData {
                self.patternTableView.isHidden = false
                self.wordTableView.isHidden = true
                self.selectedTableView = self.patternTableView
            }
        case 1:
            loadWordData {
                self.patternTableView.isHidden = true
                self.wordTableView.isHidden = false
                self.selectedTableView = self.wordTableView
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
