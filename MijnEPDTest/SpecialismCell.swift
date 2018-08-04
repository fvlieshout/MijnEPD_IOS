//
//  SpecialismCell.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class SpecialismCell: UITableViewCell {

    
    @IBOutlet weak var specialismImageView: UIImageView!
    @IBOutlet weak var specialismTitle: UILabel!
    
    func setSpecialism(specialism: Specialism) {
        specialismImageView.image = specialism.image
        specialismTitle.text = specialism.title
    }
}
