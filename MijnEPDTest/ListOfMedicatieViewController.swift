//
//  ListOfMedicatieViewController.swift
//  MijnEPDTest
//
//  Created by Noel Bainathsah on 09-09-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation
class ListOfMedicatieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableViewer: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var medicatieDocuments: [String] = []
    var medicatieData: [String] = []
    let dbController = DatabaseConnector()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationBar.title = "Medicatie"
        createLabuitslagDocumentEnDataArray()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicatieDocuments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell") as! DocumentCell
        cell.setDocumentValues(title: medicatieDocuments[indexPath.row], date: medicatieData[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //beschrijft wat er moet gebeuren als er op één rij wordt geklikt
        let documentTemp = medicatieDocuments[indexPath.row]
        gekozenDocument = documentTemp //hier wordt de globale variable ingesteld die dus ook in andere classes en viewControllers bereikbaar is
        
        self.performSegue(withIdentifier: "naarKijkDocument", sender: self)
        
    }
    
    
    //Maakt een array aan met alle documenten (documents) en een array met alle datums van de documenten (data)
    func createLabuitslagDocumentEnDataArray() {
        medicatieDocuments = dbController.getMedicatieDocumentenArray()
        medicatieData = dbController.getDataMedicatieDocumentenArray()
    }
}
