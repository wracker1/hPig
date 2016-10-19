//
//  ChannelController.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 19..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire
import CoreGraphics

class ChannelController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var id: String? = nil
    var data: Channel? = nil

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bannerView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watcherCntLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var sessionsView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        let ratio: CGFloat = 1
        let margin: CGFloat = 15
        let width = (view.bounds.size.width / 2) - margin
        
        flowLayout.itemSize = CGSize(width: width, height: width * ratio)

        if let channelId = id {
            NetService.shared.getObject(path: "/svc/api/channel/\(channelId)", completionHandler: { (res: DataResponse<Channel>) in
                self.data = res.result.value
                self.loadData()
                self.sessionsView.reloadData()
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadData() {
        if let channel = data {
            self.title = channel.name
            self.titleLabel.text = channel.name
            self.watcherCntLabel.text = channel.subCnt
            self.descLabel.text = channel.desc
            
            ImageDownloadService.shared.get(url: channel.image, filter: nil, completionHandler: { (res) in
                self.imageView.image = res.result.value
            })
            
            ImageDownloadService.shared.get(url: channel.banner, filter: nil, completionHandler: { (res) in
                self.bannerView.image = res.result.value
            })
        }
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
}
