//
//  ListOfOnderzoekenViewController.swift
//  MijnEPDTest
//
//  Created by Miró Scholten on 07-09-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation

class ListOfOnderzoekenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableViewer: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var labuitslagDocuments: [String] = []
    var labuitslagData: [String] = []
    let dbController = DatabaseConnector()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationBar.title = "Labuitslagen"
        createLabuitslagDocumentEnDataArray()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labuitslagDocuments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell") as! DocumentCell
        cell.setDocumentValues(title: labuitslagDocuments[indexPath.row], date: labuitslagData[indexPath.row])
        return cell
        
    }
    
    
    //Maakt een array aan met alle documenten (documents) en een array met alle datums van de documenten (data)
    func createLabuitslagDocumentEnDataArray() {
        labuitslagDocuments = dbController.getLabuitslagenDocumentenArray()
        labuitslagData = dbController.getDataLabuitslagenDocumentenArray()
    }
}

