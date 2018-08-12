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
    
    @IBOutlet weak var myContextMenu: UIView!
    @IBOutlet weak var restOfScreenView: UIButton!
    
    var folders: [FolderClass] = []
    let dbController = DatabaseConnector()
    let toast = ToastMessage()
    var gekozenMap = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maakNieuweMapView.layer.borderColor = UIColor.black.cgColor
        maakNieuweMapView.layer.borderWidth = 1
        maakNieuweMapView.isHidden = true
        myContextMenu.isHidden = true
        addShadowToView(view: myContextMenu)
        navigationBar.title = gekozenSpecialisme
        
        folders = createFolderArray()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ListOfFoldersViewController.handleLongPress))
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                gekozenMap = folders[indexPath.row].name
                print("Geselecteerde map: " + gekozenMap)
                
                let ycoordinaat = touchPoint.y + 70
                myContextMenu.frame.origin.y = ycoordinaat
                restOfScreenView.isHidden = false
                myContextMenu.isHidden = false
                
                
            }
        }
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
        restOfScreenView.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.7)
        restOfScreenView.isHidden = false
    }
    
    @IBAction func mapAanmakenAnnuleren(_ sender: Any) {
        mapNaamTextfield.text = ""
        maakNieuweMapView.isHidden = true
        restOfScreenView.isHidden = true
        restOfScreenView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
    }
    @IBAction func mapAanmakenOpslaan(_ sender: Any) {
        let mapNaam = mapNaamTextfield.text
        do {
            try dbController.insertMap(mapNaam: mapNaam!, specialisme: gekozenSpecialisme)
            folders = createFolderArray()
            tableView.reloadData()
            mapNaamTextfield.text = ""
            maakNieuweMapView.isHidden = true
            restOfScreenView.isHidden = true
            restOfScreenView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
        } catch (MyError.bestaandeMapError()) {
            print("Map bestaat al")
            let message = "Er bestaat in dit specialisme al een map met die naam. Kies een andere naam."
            toast.displayToast(message: message, duration: 3, viewController: self)
        } catch {
            print("Unexpected error: \(error).")
            let message = "Unexpected error"
            toast.displayToast(message: message, duration: 3, viewController: self)
            mapNaamTextfield.text = ""
            maakNieuweMapView.isHidden = true
            restOfScreenView.isHidden = true
            restOfScreenView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
        }
    }
    
    @IBAction func verwijderMap(_ sender: Any) {
        dbController.deleteMap(mapNaam: gekozenMap, specialisme: gekozenSpecialisme)
        myContextMenu.isHidden = true
        folders = createFolderArray()
        tableView.reloadData()
    }
    @IBAction func wijzigMapnaam(_ sender: Any) {
    }
    
    @IBAction func restOfScreenTapped(_ sender: Any) {
        myContextMenu.isHidden = true
        maakNieuweMapView.isHidden = true
        restOfScreenView.isHidden = true
        restOfScreenView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
    }
    
    private func addShadowToView (view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 6
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
}
