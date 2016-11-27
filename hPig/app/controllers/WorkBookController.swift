//
//  WorkBookController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData
import CoreGraphics

class WorkBookController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segMenu: UISegmentedControl!
    @IBOutlet weak var patternTableView: UITableView!
    @IBOutlet weak var wordTableView: UITableView!
    
    @IBOutlet var patternView: UIView!
    @IBOutlet weak var ptScrollContentView: UIView!
    @IBOutlet weak var ptScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ptEnglishLabel: UILabel!
    @IBOutlet weak var ptKoreanLabel: UILabel!
    @IBOutlet weak var ptMeaningLabel: UILabel!
    @IBOutlet weak var ptInfoLabel: UILabel!
    @IBOutlet weak var ptPlayButton: UIButton!
    @IBOutlet weak var ptCloseButton: UIButton!
    
    @IBOutlet var sentenceView: UIView!
    @IBOutlet weak var stSentenceLabel: UILabel!
    @IBOutlet weak var stWordLabel: UILabel!
    @IBOutlet weak var stPlayButton: UIButton!
    @IBOutlet weak var stCloseButton: UIButton!
    
    private var patternData = [PATTERN]()
    private var wordData = [WORD]()
    
    private weak var selectedTableView: UITableView? = nil
    private var selectedPattern: PATTERN? = nil
    private var selectedWord: WORD? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("pattern_view", owner: self, options: nil)
        Bundle.main.loadNibNamed("sentence_layer", owner: self, options: nil)
        
        ptCloseButton.layer.borderColor = secondPointColor.cgColor
        ptCloseButton.layer.borderWidth = 1.0
        
        stCloseButton.layer.borderColor = secondPointColor.cgColor
        stCloseButton.layer.borderWidth = 1.0
        
        ptCloseButton.addTarget(self, action: #selector(self.closeModal), for: .touchUpInside)
        stCloseButton.addTarget(self, action: #selector(self.closeModal), for: .touchUpInside)
    }
    
    func closeModal() {
        self.dismiss(animated: true, completion: nil)
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
        var alert: UIAlertController? = nil
        
        switch tableView {
        case patternTableView:
            if let pattern = patternData.get(indexPath.row) {
                let candidate = self.view.bounds.size.height - 200
                ptScrollViewHeight.constant = candidate
                updatePatternView(pattern)
                
                alert = embed(view: patternView)
            }
            
        case wordTableView:
            if let word = wordData.get(indexPath.row) {
                updateSentenceView(word)
                alert = embed(view: sentenceView)
            }
            
        default:
            break
        }
        
        if let alertController = alert {
            alertController.popoverPresentationController?.sourceView = tableView
            alertController.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            self.present(alertController, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    private func embed(view item: UIView, height: CGFloat? = nil) -> UIAlertController {
        let actionSheetWidth = self.view.bounds.size.width - 20
        
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "", style: .cancel, handler: nil))
        alert.view.addSubview(item)
        
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        item.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["view" : item]
        
        alert.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view(==\(actionSheetWidth))]|",
                options: .alignAllCenterY,
                metrics: nil,
                views: views))
        
        let verticalConst = height == nil ? "V:|-[view]-|" : "V:|-[view(>=\(height ?? 0))]-|"
        
        alert.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: verticalConst,
                options: .alignAllCenterX,
                metrics: nil,
                views: views))
        
        return alert
    }
    
    func updatePatternView(_ pattern: PATTERN) {
        if let english = pattern.english, let korean = pattern.korean, let meaning = pattern.mean, let info = pattern.info {
            ptEnglishLabel.attributedText = SubtitleService.shared.buildAttributedString(english)
            ptKoreanLabel.text = korean
            ptMeaningLabel.text = meaning
            ptInfoLabel.text = info
            
            self.selectedPattern = pattern
        }
    }
    
    func updateSentenceView(_ word: WORD) {
        if let sentence = word.sentence, let item = word.word {
            let range = (sentence as NSString).range(of: item, options: .caseInsensitive)
            let attributedString = NSMutableAttributedString(string: sentence)
            attributedString.addAttributes([NSForegroundColorAttributeName: SubtitlePointColor], range: range)

            stSentenceLabel.attributedText = attributedString
            stWordLabel.text = word.korean
            
            self.selectedWord = word
        }
    }
    
    @IBAction func playPatternStudy(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "patternStudyFromWorkBook", sender: nil)
        })
    }
    
    @IBAction func playBasicStudy(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "basicStudyFromWorkBook", sender: nil)
        })
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
        
        if let patternStudyController = viewController as? PatternStudyController {
            
            if let button = sender as? UIButton,
                let cell = button.superview?.superview as? UITableViewCell,
                let indexPath = patternTableView.indexPath(for: cell),
                let data = patternData.get(indexPath.row) {
                
                preparePattern(controller: patternStudyController, pattern: data)
            } else if let data = selectedPattern {
                preparePattern(controller: patternStudyController, pattern: data)
            }
        } else if let basicStudyController = viewController as? BasicStudyController {
            
            if let data = selectedWord {
                basicStudyController.session = Session(data)
                basicStudyController.startTime = data.time
                
            }
        }
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let button = sender as? PatternImageButton, let pattern = button.pattern {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: Session(pattern))
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
        }
    }
    
    private func preparePattern(controller: PatternStudyController, pattern: PATTERN) {
        if let position = pattern.position, let patternIndex = Int(position) {
            controller.session = Session(pattern)
            controller.currentIndex = patternIndex
        }
    }
}
