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
    @IBOutlet weak var closeButton: UIButton!
    
    private var cache = [String: [Session]]()
    private var results: (String, [Session])? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 150

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.1.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        if let searchCell = cell as? SearchCell,
            let keyword = results?.0,
            let session = results?.1.get(indexPath.row) {
        
            searchCell.update(keyword, session: session)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func toggleCloseButtonStyle(_ isEditing: Bool) {
        if isEditing {
            closeButton.setImage(nil, for: .normal)
            closeButton.setTitle("취소", for: .normal)
        } else {
            closeButton.setImage(#imageLiteral(resourceName: "btn_close"), for: .normal)
            closeButton.setTitle(nil, for: .normal)
        }
    }
    
    private func reloadData(_ keyword: String, data: [Session]) {
        self.results = (keyword, data)
        
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let shouldEdit = true
        
        toggleCloseButtonStyle(shouldEdit)
        
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
        
        toggleCloseButtonStyle(false)
    }

    @IBAction func dismiss(_ sender: Any) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            
            toggleCloseButtonStyle(false)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
