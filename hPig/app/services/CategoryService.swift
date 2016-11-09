//
//  CategoryService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire

class CategoryService: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    static let shared: CategoryService = {
        let instance = CategoryService()
        return instance
    }()
    
    private weak var viewController: UIViewController? = nil
    private var filterSelectionBlock: ((String?, String?, String?) -> Void)? = nil
    private var initialized = false
    
    let picker = hActionPickerController(title: "카테고리", message: nil)
    
    private var categories: [Category] = []
    private let sortData = [["name": "최신", "id": "new"], ["name": "인기", "id": "viewcnt"], ["name": "무료", "id": "free"]]
    private let levelData = [["name": "전체", "id": "0"], ["name": "초급", "id": "1"], ["name": "중급", "id": "2"], ["name": "고급", "id": "3"]]
    
    func categoryById(_ id: String) -> String? {
        return categories.find({ (item) -> Bool in
            return item.id == id
        }).map({ (item) -> String in
            return item.name
        })
    }
    
    func sortById(_ id: String) -> String? {
        return sortData.find({ (dict) -> Bool in
            if let itemId = dict["id"] {
                return itemId == id
            } else {
                return false
            }
        }).flatMap({ (dict) -> String? in
            return dict["name"]
        })
    }
    
    func levelById(_ id: String) -> String? {
        return levelData.find({ (dict) -> Bool in
            if let itemId = dict["id"] {
                return itemId == id
            } else {
                return false
            }
        }).flatMap({ (dict) -> String? in
            return dict["name"]
        })
    }
    
    private func initPicker(completion: @escaping () -> Void) {
        if initialized {
            completion()
        } else {
            picker.dataSource = self
            picker.delegate = self
            
            picker.pickerView?.closeButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
            picker.pickerView?.confirmButton.addTarget(self, action: #selector(self.done), for: .touchUpInside)
            
            NetService.shared.getCollection(path: "/svc/api/category", completionHandler: { (res: DataResponse<[Category]>) in
                if let data = res.result.value {
                    self.categories = data
                    self.initialized = true
                    completion()
                }
            })
        }
    }
    
    func cancel() {
        if let vc = viewController {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    func done() {
        let category = categories[picker.selectedRowInComponent(component: 0) ?? 0].id
        let level = levelData[picker.selectedRowInComponent(component: 1) ?? 0]["id"]
        let sort = sortData[picker.selectedRowInComponent(component: 2) ?? 0]["id"]
        
        if let completion = filterSelectionBlock {
            completion(sort, category, level)
            cancel()
        }
    }
    
    func presentSessionListFilter(viewController: UIViewController,
                                  sort: String,
                                  category: String,
                                  level: String,
                                  completion: @escaping (_ sort: String?, _ category: String?, _ level: String?) -> Void) {
        
        self.picker.controller?.popoverPresentationController?.barButtonItem = viewController.navigationItem.leftBarButtonItem
        
        self.initPicker {
            self.viewController = viewController
            self.filterSelectionBlock = completion
            
            let categoryIndex = self.categories.index { (data) -> Bool in
                return data.id == category
            }
            
            self.picker.selectRow(row: categoryIndex ?? 0, inComponent: 0, animated: false)
            
            let levelIndex = self.levelData.index { (data) -> Bool in
                return data["id"] == level
            }
            
            self.picker.selectRow(row: levelIndex ?? 0, inComponent: 1, animated: false)
            
            
            let sortIndex = self.sortData.index { (data) -> Bool in
                return data["id"] == sort
            }
            
            self.picker.selectRow(row: sortIndex ?? 0, inComponent: 2, animated: false)
            
            if let controller = self.picker.controller {
                viewController.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return categories.count
        } else if component == 1 {
            return levelData.count
        } else {
            return sortData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return categories[row].name
        } else if component == 1 {
            return levelData[row]["name"]
        } else {
            return sortData[row]["name"]
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
}
