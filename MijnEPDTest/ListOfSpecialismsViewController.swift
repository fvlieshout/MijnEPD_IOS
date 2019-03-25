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
    @IBAction func nieuwDocumentToevoegen(_ sender: Any) {
        gekozenSpecialisme = ""
        self.performSegue(withIdentifier: "nieuwDocumentSegue", sender: self)
    }
    
    var specialisms: [Specialism] = []
    let dbController = DatabaseConnector()

    override func viewDidLoad() {
        super.viewDidLoad()
        specialisms = dbController.getSpecialismenArrayMetPlaatjes()
    }
    @IBAction func toonInfo(_ sender: Any) {
        self.performSegue(withIdentifier: "toonInformatie", sender: self)
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

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            var theSegueDataTypeOnderzoek = ""
            if (gekozenSpecialisme == "Labuitslagen" || gekozenSpecialisme == "Rontgenonderzoeken" || gekozenSpecialisme == "Medicatie") {
            theSegueDataTypeOnderzoek = gekozenSpecialisme
            let destinationVC = segue.destination as! ListOfMedicatieViewController
            destinationVC.segueDataTypeOnderzoek = theSegueDataTypeOnderzoek
            }
        }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //beschrijft wat er moet gebeuren als er op één rij wordt geklikt
        let specialismTemp = specialisms[indexPath.row]
        gekozenSpecialisme = specialismTemp.title //hier wordt de globale variable ingesteld die dus ook in andere classes en viewControllers bereikbaar is
        let destinationVC = ListOfMedicatieViewController()
        destinationVC.segueDataTypeOnderzoek = gekozenSpecialisme
        
        if (gekozenSpecialisme == "Labuitslagen") {
            self.performSegue(withIdentifier: "naarTest", sender: self)
        } else if (gekozenSpecialisme == "Rontgenonderzoeken" ) {
            self.performSegue(withIdentifier: "naarTest", sender: self)
        } else if (gekozenSpecialisme == "Medicatie" ) {
            self.performSegue(withIdentifier: "naarTest", sender: self)
        } else { self.performSegue(withIdentifier: "naarMappen", sender: self)
            
        }
    }
}
