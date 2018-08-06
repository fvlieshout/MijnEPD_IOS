//
//  ListOfSpecialismsViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

var gekozenSpecialisme = ""

class ListOfSpecialismsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var specialisms: [Specialism] = []
    let dbController = DatabaseConnector()

    override func viewDidLoad() {
        super.viewDidLoad()
        specialisms = dbController.getSpecialismenArrayMetPlaatjes()

        // Do any additional setup after loading the view.
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specialismTemp = specialisms[indexPath.row]
        gekozenSpecialisme = specialismTemp.title
        self.performSegue(withIdentifier: "naarMappen", sender: self)
    }
}
