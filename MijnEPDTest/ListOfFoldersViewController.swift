//
//  ListOfFoldersViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class ListOfFoldersViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var maakNieuweMapView: UIView!
    @IBOutlet weak var mapNaamTextfield: UITextField!
    
    var folders: [FolderClass] = []
    let dbController = DatabaseConnector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maakNieuweMapView.isHidden = true
        navigationBar.title = gekozenSpecialisme
        folders = createFolderArray()
    }
}

extension ListOfFoldersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let folderTemp = folders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell") as! FolderCell
        cell.setFolders(folder: folderTemp)
        
        return cell
    }
    
    func createFolderArray() -> [FolderClass] {
        var tempArray: [FolderClass] = []
        let stringArray = dbController.getMappenArray(hetGekozenSpecialisme: gekozenSpecialisme)
        for map in stringArray {
            let mapje = FolderClass(name: map)
            tempArray.append(mapje)
        }
        return tempArray
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let specialismTemp = specialisms[indexPath.row]
    //        let specialismString = specialismTemp.title
    //        self.performSegue(withIdentifier: "naarMappen", sender: self)
    //    }
    
    @IBAction func maakNieuweMap(_ sender: Any) {
        maakNieuweMapView.isHidden = false
    }
    
    @IBAction func mapToevoegenAnnuleren(_ sender: Any) {
        mapNaamTextfield.text = ""
        maakNieuweMapView.isHidden = true
    }
    
    @IBAction func mapToevoegenOpslaan(_ sender: Any) {
        let deMapNaam = mapNaamTextfield.text!
        do {
            try dbController.insertMap(mapNaam: deMapNaam, specialisme: gekozenSpecialisme)
            let message = "Map '" + deMapNaam + "' is toegevoegd"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)
            
            // duration in seconds
            let duration: Double = 5
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
            }
        } catch MyError.bestaandeMapError {
            print("Deze mapnaam bestaat al")
        } catch {
            print("Unexpected error: \(error).")
        }
        mapNaamTextfield.text = ""
        maakNieuweMapView.isHidden = true
    }
    
}
