//
//  ChannelController.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 19..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire

class ChannelController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var id: String? = nil
    var data: Channel? = nil
    
    private var channelHeader: ChannelInfoCell? = nil

    @IBOutlet weak var sessionsView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ratio: CGFloat = 1
        let margin: CGFloat = 15
        let width = (view.bounds.size.width / 2) - margin
        
        flowLayout.itemSize = CGSize(width: width, height: width * ratio)
        
        if let channelId = id {
            NetService.shared.getObject(path: "/svc/api/channel/\(channelId)", completionHandler: { (res: DataResponse<Channel>) in
                self.data = res.result.value
                self.sessionsView.reloadData()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "channelInfoCell", for: indexPath)
        
        if let header = cell as? ChannelInfoCell {
            initHeader(header)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.videoList.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channelSessionCell", for: indexPath) as! ChannelSessionCell
        
        if let session = data?.videoList.get(indexPath.row) {
            cell.update(session: session)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sessionMain = segue.destination as? SessionController,
            let selected = sessionsView.indexPathsForSelectedItems,
            let indexPath = selected.first,
            let session = data?.videoList.get(indexPath.row) {
            
            sessionMain.session = session
        }
    }
    
    private func initHeader(_ item: ChannelInfoCell) {
        if channelHeader == nil, let channel = data {
            self.channelHeader = item
            
            item.loadData(channel, completion: {
                
            })
            
            self.title = channel.name
            
        }
    }
}
