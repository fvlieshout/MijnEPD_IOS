//
//  ListOfDocumentsViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 22-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class ListOfDocumentsViewController: UIViewController {
    
    @IBOutlet weak var tableViewer: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var wijzigNaamView: UIView!
    @IBOutlet weak var contextMenuView: UIView!
    
    
    var documents: [String] = []
    var data: [String] = []
    let dbController = DatabaseConnector()

    override func viewDidLoad() {
        //testdocumentjes om te kijken of dit scherm werkt
        dbController.insertDocument(titel: "Testdocumentjess", beschrijving: "Testbeschrijving1", onderzoek: 0, hetSpecialisme: "Cardiologie", artsnaam: "", uriFoto: "", datum: "12-07-2018", filepath: "")
        dbController.insertDocument(titel: "Testdocumentjess", beschrijving: "Testbeschrijving2", onderzoek: 0, hetSpecialisme: "Cardiologie", artsnaam: "", uriFoto: "", datum: "12-07-2018", filepath: "")
        
        super.viewDidLoad()
        navigationBar.title = gekozenMap
        createDocumentEnDataArray()
        wijzigNaamView.isHidden = true
        contextMenuView.isHidden = true
    }
    
    //Maakt een array aan met alle documenten (documents) en een array met alle datums van de documenten (data)
    func createDocumentEnDataArray() {
        let mapID = dbController.getMapID(mapnaam: gekozenMap, specialisme: gekozenSpecialisme)
        documents = dbController.getDocumentenArray(mapID: mapID)
        data = dbController.getDataVanDocumentenArray(mapID: mapID)
    }

}

// De uitbreiding van de class naar UITableViewDelegate en UITableViewDataSource is in een extension geplaatst om de leesbaarheid iets te vergroten
extension ListOfDocumentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell") as! DocumentCell
        cell.setDocumentValues(title: documents[indexPath.row], date: data[indexPath.row])
        return cell
    }
}
