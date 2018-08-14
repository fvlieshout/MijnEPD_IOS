//
//  ListOfSpecialismsViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//
//  Deze viewController beschrijft het gedrag van het scherm met alle specialismen onder elkaar
//

import UIKit

// Door deze variabele buiten de class te plaatsen, kan hij ook in andere ViewControllers benaderd worden
var gekozenSpecialisme = ""

class ListOfSpecialismsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var specialisms: [Specialism] = []
    let dbController = DatabaseConnector()

    override func viewDidLoad() {
        super.viewDidLoad()
        specialisms = dbController.getSpecialismenArrayMetPlaatjes()
    }
}

// De uitbreiding van de class naar UITableViewDelegate en UITableViewDataSource is in een extension geplaatst om de leesbaarheid iets te vergroten
extension ListOfSpecialismsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //beschrijft het aantal rijen in de tabel
        return specialisms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //beschrijft welke cel er getoond moet worden in elke rij
        let specialismTemp = specialisms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "specialismCell") as! SpecialismCell
        cell.setSpecialism(specialism: specialismTemp)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //beschrijft wat er moet gebeuren als er op één rij wordt geklikt
        let specialismTemp = specialisms[indexPath.row]
        gekozenSpecialisme = specialismTemp.title //hier wordt de globale variable ingesteld die dus ook in andere classes en viewControllers bereikbaar is
        self.performSegue(withIdentifier: "naarMappen", sender: self)
    }
}
