//
//  hCollectionViewLayout.swift
//  hPig
//
//  Created by 이동현 on 2016. 12. 23..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

protocol hCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

class hCollectionViewLayout: UICollectionViewLayout {
    
    private let minWidth: CGFloat = 100
    private var cache = [String: UICollectionViewLayoutAttributes]()
    
    private var delegate: hCollectionViewLayoutDelegate? = nil
    private var maxWidth: CGFloat = 0
    private var itemInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    private var contentHeight: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_ delegate: hCollectionViewLayoutDelegate, itemMaxWidth: CGFloat, insets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)) {
        super.init()
        
        self.delegate = delegate
        self.maxWidth = itemMaxWidth
        self.itemInsets = insets
    }
    
    private func numberOfColumns() -> Int {
        let width = collectionView?.contentSize.width ?? 0
        
        if width == 0 {
            return 0
        } else {
            if maxWidth >= width  {
                return 1
            } else {
                let col = Int(width) / Int(maxWidth)
                let mod = Int(width) % Int(maxWidth)
                
                if mod > Int(minWidth) {
                    return col + 1
                } else {
                    return col
                }
            }
        }
    }
    
    private func keyForIndexPath(_ indexPath: IndexPath) -> String {
        return "\(indexPath.item):\(indexPath.section)"
    }
    
    override func prepare() {
        if cache.isEmpty {
            let width = collectionView?.contentSize.width ?? 0
            let sections = collectionView?.numberOfSections ?? 0
            let columns = numberOfColumns()
            let itemWidth = width / CGFloat(columns)
            
            let xOffsets = (0..<columns).map { (i) -> CGFloat in
                let leftMargin = CGFloat(i + 1) * self.itemInsets.left
                let rightMargin = CGFloat(i) * self.itemInsets.right
                return (CGFloat(i) * itemWidth) + leftMargin + rightMargin
            }
            
            var yOffsets: [CGFloat] = (0..<columns).map({ (_) -> CGFloat in
                return 0
            })
            
            for section in 0..<sections {
                let items = collectionView?.numberOfItems(inSection: section) ?? 0
                
                for item in 0..<items {
                    let col = item % columns
                    let indexPath = IndexPath(item: item, section: section)
                    
                    let x = xOffsets[col]
                    let y = yOffsets[col] + itemInsets.top
                    let height = delegate?.collectionView(collectionView!, heightForItemAt: indexPath, withWidth: itemWidth) ?? 0
                    let rect = CGRect(x: x, y: y, width: itemWidth, height: height)
                    
                    let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attr.frame = rect
                    yOffsets[col] = height + itemInsets.bottom
                    
                    cache[keyForIndexPath(indexPath)] = attr
                }
            }
            
            yOffsets.forEach({ (offset) in
                self.contentHeight = max(contentHeight, offset)
            })
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return cache.flatMap({ (_, attr) -> UICollectionViewLayoutAttributes? in
            if attr.frame.intersects(rect) {
                return attr
            } else {
                return nil
            }
        })
    }
    
    override var collectionViewContentSize: CGSize {
        if let view = collectionView {
            let width = view.bounds.size.width - (view.contentInset.left + view.contentInset.right)
            return CGSize(width: width, height: contentHeight)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
