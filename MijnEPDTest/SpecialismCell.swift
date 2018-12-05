//
//  SpecialismCell.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//
//  Custom cell die gebruikt wordt in het scherm waarin de specialismen worden getoond. Deze custom cell zorgt ervoor dat er altijd een plaatje van het specialisme en de naam van het specialisme worden getoond

import UIKit

class SpecialismCell: UITableViewCell {

    
    @IBOutlet weak var specialismImageView: UIImageView!
    @IBOutlet weak var specialismTitle: UILabel!
    
    /**
     Vult de cel in met de juiste gegevens
     - Parameter specialism: het specialisme waarvan de gegevens moeten worden ingevuld in de cel
    */
    func setSpecialism(specialism: Specialism) {
        specialismImageView.image = specialism.image
        specialismTitle.text = specialism.title
    }
}
