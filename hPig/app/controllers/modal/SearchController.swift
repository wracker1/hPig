//
//  SearchController.swift
//  hPig
//
//  Created by 이동현 on 2017. 2. 26..
//  Copyright © 2017년 wearespeakingtube. All rights reserved.
//

import UIKit

class SearchController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    private var cache = [String: [Session]]()
    private var results: (String, [Session])? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "찾기"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.1.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath)
        
        if let sessionCell = cell as? SessionCell,
            let keyword = results?.0,
            let session = results?.1.get(indexPath.row) {
        
            sessionCell.update(session, with: keyword)
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let channelController = segue.destination as? ChannelController,
            let button = sender as? ChannelButton,
            let session = button.session {
            
            channelController.id = session.channelId
        } else if let sessionController = segue.destination as? SessionController{
            let index = self.tableView.indexPathForSelectedRow?.row
            if let session = results?.1.get(index!), let type = session.type?.lowercased(), type != "banner" {
                sessionController.session = session
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = self.tableView.indexPathForSelectedRow,
            let session = results?.1.get(indexPath.row) {
            
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: session)
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
        }
    }
    
    private func reloadData(_ keyword: String, data: [Session]) {
        self.results = (keyword, data)
        
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let shouldEdit = true
        
        return shouldEdit
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyword = searchBar.text, keyword.characters.count > 1 {
            if let cached = cache[keyword] {
                reloadData(keyword, data: cached)
            } else {
                ApiService.shared.search(keyword, completion: { (sessions) in
                    if sessions.count > 0 {
                        self.cache[keyword] = sessions
                    }

                    self.reloadData(keyword, data: sessions)
                })
            }
        } else {
            self.view.presentToast("2자 이상의 검색어를 입력 해주세요.")
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}
