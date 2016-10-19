//
//  WordCell.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 19..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class WordCell: UITableViewCell, hTableViewCell {

    typealias Item = WORD
    @IBOutlet weak var englishDictionaryView: hEnglishDictionaryView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let button = englishDictionaryView.confirmButton {
            button.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update(data: Item) -> UITableViewCell {
        if let item = WordData(data) {
            englishDictionaryView.update(data: item, completion: nil)
        }
        
        return self
    }
}
