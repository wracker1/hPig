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
        } else if tableView == wordTableView, let word = wordData.get(indexPath.row) {
            wordData.remove(at: indexPath.row)
            dataService.delete(model: word)
        }
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        dataService.save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case patternTableView:
            if let pattern = patternData.get(indexPath.row) {
                let item = PatternView(frame: CGRectZero)
                //AlertService.shared.presentActionSheet(self, view: item, completion: nil)
                let alert = AlertService.shared.actionSheet(item)
                
                self.present(alert, animated: true, completion: nil)
                
                item.update(pattern: pattern)
            }
            
        case wordTableView:
            if let word = wordData.get(indexPath.row) {
                let item = SentenceLayer(frame: CGRectZero)
                AlertService.shared.presentActionSheet(self, view: item, completion: nil)
                item.update(word)
            }
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
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
        } else if tableView == wordTableView, let word = wordData.get(indexPath.row), let wordCell = cell as? WordCell {
            return wordCell.update(data: word)
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
        AuthenticateService.shared.userId { (userId) in
            let dataService = CoreDataService.shared
            let req: NSFetchRequest<PATTERN> = PATTERN.fetchRequest()
            req.sortDescriptors = [NSSortDescriptor(key: "regdt", ascending: false)]
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
    }
    
    private func loadWordData(completion: (() -> Void)?) {
        AuthenticateService.shared.userId { (userId) in
            let dataService = CoreDataService.shared
            let req: NSFetchRequest<WORD> = WORD.fetchRequest()
            let query = "uid = '\(userId)'"
            req.predicate = NSPredicate(format: query)
            req.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false), NSSortDescriptor(key: "regdt", ascending: false)]
            
            dataService.select(request: req) { (items, error) in
                self.wordData = items
                self.wordTableView.reloadData()
                
                if let callback = completion {
                    callback()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = (segue.destination as! UINavigationController).topViewController
        
        if let patternStudyController = viewController as? PatternStudyController,
            let button = sender as? UIButton,
            let cell = button.superview?.superview as? UITableViewCell,
            let indexPath = patternTableView.indexPath(for: cell),
            let data = patternData.get(indexPath.row),
            let position = data.position,
            let patternIndex = Int(position) {
            
            patternStudyController.session = Session(data)
            patternStudyController.currentIndex = patternIndex
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let button = sender as? PatternImageButton, let pattern = button.pattern {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: Session(pattern))
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
        }
    }
}
