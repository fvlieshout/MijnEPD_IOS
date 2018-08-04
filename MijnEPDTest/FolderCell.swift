//
//  FolderCell.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class FolderCell: UITableViewCell {

    
    @IBOutlet weak var folderImage: UIImageView!
    @IBOutlet weak var folderTitle: UILabel!
    
    func setFolders(folder: FolderClass) {
        folderImage.image = #imageLiteral(resourceName: "very-basic-folder-icon")
        folderTitle.text = folder.name
    }

}
