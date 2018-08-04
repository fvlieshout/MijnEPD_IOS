//
//  ListOfSpecialismsViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class ListOfSpecialismsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var specialisms: [Specialism] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        specialisms = createSpecialismArray()

        // Do any additional setup after loading the view.
    }
    
    func createSpecialismArray() -> [Specialism] {
        var tempArray: [Specialism] = []
        
        let bloedonderzoeken = Specialism(image: #imageLiteral(resourceName: "bloedonderzoek_zwart"), title: "Bloedonderzoeken")
        let onderzoeken = Specialism(image: #imageLiteral(resourceName: "onderzoek_zwart"), title: "Onderzoeken")
        let medicatie = Specialism(image: #imageLiteral(resourceName: "Three"), title: "Medicatie")
        let anesthesiologie = Specialism(image: #imageLiteral(resourceName: "anesthesiologie"), title: "Anesthesiologie")
        let cardiologie = Specialism(image: #imageLiteral(resourceName: "cardio"), title: "Cardiologie")
        let dermatologie = Specialism(image: #imageLiteral(resourceName: "dermatologie"), title: "Dermatologie")
        let gynaecologie = Specialism(image: #imageLiteral(resourceName: "crawling-baby-icons-70277"), title: "Gynaecologie")
        let huisartsgeneeskunde = Specialism(image: #imageLiteral(resourceName: "stethoscope1600"), title: "Huisartsgeneeskunde")
        let keelNeusOorheelkunde = Specialism(image: #imageLiteral(resourceName: "c992214a0de3025070a22a1a4c275dcb"), title: "Keel-neus-oorheelkunde")
        let kindergeneeskunde = Specialism(image: #imageLiteral(resourceName: "kindergeneeskunde"), title: "Kindergeneeskunde")
        let klinischeGenetica = Specialism(image: #imageLiteral(resourceName: "consult-icon-genetic"), title: "Klinische genetica")
        let longgeneeskunde = Specialism(image: #imageLiteral(resourceName: "lungs-512"), title: "Longgeneeskunde")
        let maagDarmLeverziekten = Specialism(image: #imageLiteral(resourceName: "mdl"), title: "Maag-darm-leverziekten")
        let neurologie = Specialism(image: #imageLiteral(resourceName: "brain-2"), title: "neurologie")
        let oogheelkunde = Specialism(image: #imageLiteral(resourceName: "oog"), title: "oogheelkunde")
        let psychiatrie = Specialism(image: #imageLiteral(resourceName: "psychiatrie"), title: "psychiatrie")
        
        tempArray.append(bloedonderzoeken)
        tempArray.append(onderzoeken)
        tempArray.append(medicatie)
        tempArray.append(anesthesiologie)
        tempArray.append(cardiologie)
        tempArray.append(dermatologie)
        tempArray.append(gynaecologie)
        tempArray.append(huisartsgeneeskunde)
        tempArray.append(keelNeusOorheelkunde)
        tempArray.append(kindergeneeskunde)
        tempArray.append(klinischeGenetica)
        tempArray.append(longgeneeskunde)
        tempArray.append(maagDarmLeverziekten)
        tempArray.append(neurologie)
        tempArray.append(oogheelkunde)
        tempArray.append(psychiatrie)
        
        return tempArray
    }
}

extension ListOfSpecialismsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specialisms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let specialismTemp = specialisms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "specialismCell") as! SpecialismCell
        cell.setSpecialism(specialism: specialismTemp)
        
        return cell
    }
}
