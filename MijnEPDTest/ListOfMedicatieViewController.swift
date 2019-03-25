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
    
    var onderzoekDocuments: [String] = []
    var onderzoeksData: [String] = []
    let dbController = DatabaseConnector()
    var segueDataTypeOnderzoek: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if (segueDataTypeOnderzoek == "Medicatie") {
            navigationBar.title = "Medicatie"
        }
        else if (segueDataTypeOnderzoek == "Rontgenonderzoeken") {
            navigationBar.title = "Rontgenonderzoeken"
        }
        else if (segueDataTypeOnderzoek == "Labuitslagen") {
            navigationBar.title = "Labuitslagen"
        }
        
        createLabuitslagDocumentEnDataArray()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onderzoekDocuments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell") as! DocumentCell
        cell.setDocumentValues(title: onderzoekDocuments[indexPath.row], date: onderzoeksData[indexPath.row])
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let theSegueData = "Onderzoek"
        
        let destinationVC = segue.destination as! ViewDocumentViewController
        destinationVC.segueData = theSegueData
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //beschrijft wat er moet gebeuren als er op één rij wordt geklikt
        let documentTemp = onderzoekDocuments[indexPath.row]
        gekozenDocument = documentTemp //hier wordt de globale variable ingesteld die dus ook in andere classes en viewControllers bereikbaar is
        let destinationVC = ViewDocumentViewController()
        destinationVC.segueData = documentTemp
        self.performSegue(withIdentifier: "naarKijkDocument", sender: self)
        
    }
    
    
    //Maakt een array aan met alle documenten (documents) en een array met alle datums van de documenten (data)
    func createLabuitslagDocumentEnDataArray() {
        if (segueDataTypeOnderzoek == "Medicatie") {
        onderzoekDocuments = dbController.getMedicatieDocumentenArray()
        onderzoeksData = dbController.getDataMedicatieDocumentenArray()
        }
        else if (segueDataTypeOnderzoek == "Rontgenonderzoeken") {
            onderzoekDocuments = dbController.getRontgenDocumentenArray()
            onderzoeksData = dbController.getDataRontgenDocumentenArray()
        }
        else if (segueDataTypeOnderzoek == "Labuitslagen") {
            onderzoekDocuments = dbController.getLabuitslagenDocumentenArray()
            onderzoeksData = dbController.getDataLabuitslagenDocumentenArray()
        }
    }
}
