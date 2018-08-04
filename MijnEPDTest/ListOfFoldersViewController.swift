//
//  ListOfFoldersViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class ListOfFoldersViewController: UIViewController {
    var folders: [FolderClass] = []
    
    @IBOutlet weak var folderTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        folders = createFolderArray()
        
        // Do any additional setup after loading the view.
    }
    
    func createFolderArray() -> [FolderClass] {
        var tempArray: [FolderClass] = []
        
        let mapEen = FolderClass(name: "Map 1")
        
        tempArray.append(mapEen)
        
        return tempArray
    }
}

extension ListOfFoldersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let folderTemp = folders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell") as! FolderCell
        cell.setFolders(folder: folderTemp)
        
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let specialismTemp = specialisms[indexPath.row]
//        let specialismString = specialismTemp.title
//        self.performSegue(withIdentifier: "naarMappen", sender: self)
//    }

}
