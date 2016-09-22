//
//  hActionPickerController.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class hActionPickerController {
    var controller: UIAlertController? = nil
    
    var pickerView: hPickerView? = nil
    
    var delegate: UIPickerViewDelegate? {
        get {
            return pickerView?.pickerView.delegate
        }
        set {
            pickerView?.pickerView.delegate = newValue
        }
    }
    
    var dataSource: UIPickerViewDataSource? {
        get {
            return pickerView?.pickerView.dataSource
        }
        set {
            pickerView?.pickerView.dataSource = newValue
        }
    }
    
    func selectedRowInComponent(component: Int) -> Int? {
        return pickerView?.pickerView.selectedRow(inComponent: component)
    }
    
    func selectRow(row: Int, inComponent: Int, animated: Bool) {
        pickerView?.pickerView.selectRow(row, inComponent: inComponent, animated: animated)
    }
    
    
    
    init(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let picker = hPickerView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        picker.layer.cornerRadius = 8.0
        picker.clipsToBounds = true
        
        alertController.view.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        alertController.view.addSubview(picker)
        picker.titleLabel.text = title
        
        self.controller = alertController
        self.pickerView = picker
        
        let views = ["view": picker]
        
        alertController.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[view]|",
                options: .alignAllCenterY,
                metrics: nil,
                views: views)
        )
        
        alertController.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[view]|",
                options: .alignAllCenterX,
                metrics: nil,
                views: views
            )
        )
    }
}
