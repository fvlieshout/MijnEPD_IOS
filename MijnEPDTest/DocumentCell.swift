//
//  DocumentCell.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 22-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var documentImage: UIImageView!
    @IBOutlet weak var documentTitle: UILabel!
    @IBOutlet weak var documentDate: UILabel!
    
    /**
     Vult de cel in met de juiste informatie
     - Parameter folder: de map waarvan de informatie in de cel moet worden ingevuld
     */
    func setDocumentValues(title: String, date: String) {
        documentImage.image = #imageLiteral(resourceName: "Documents button")
        documentTitle.text = title
        documentDate.text = date
    }
    
}
