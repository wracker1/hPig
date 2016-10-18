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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update(data: Item) -> UITableViewCell {
        if let word = data.word, let _ = data.pron {
            self.textLabel?.text = word
            self.detailTextLabel?.text = data.summary
        }
        
        return self
    }
}
