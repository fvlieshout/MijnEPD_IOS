//
//  FolderCell.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//
// Custom cell die gebruikt wordt in het scherm waarin de mappen worden getoond. Deze custom cell zorgt ervoor dat er altijd een mapplaatje en de naam van de map worden getoond

import UIKit

class FolderCell: UITableViewCell {

    @IBOutlet weak var folderImage: UIImageView!
    @IBOutlet weak var folderTitle: UILabel!
    
    /**
     Vult de cel in met de juiste informatie
     - Parameter folder: de map waarvan de informatie in de cel moet worden ingevuld
    */
    func setFolders(folder: FolderClass) {
        folderImage.image = #imageLiteral(resourceName: "very-basic-folder-icon")
        folderTitle.text = folder.name
    }

}
