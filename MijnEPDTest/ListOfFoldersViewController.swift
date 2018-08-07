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
    let toast = ToastMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maakNieuweMapView.layer.borderColor = UIColor.black.cgColor
        maakNieuweMapView.layer.borderWidth = 1
        maakNieuweMapView.isHidden = true
        navigationBar.title = gekozenSpecialisme
        folders = createFolderArray()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ListOfFoldersViewController.handleLongPress))
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let mapje = folders[indexPath.row].name
                print("Geselecteerde map: " + mapje)
                guard sender.state == .began,
                    let senderView = sender.view,
                    let superView = sender.view?.superview
                    else { return }
                
                // Make responsiveView the window's first responder
                senderView.becomeFirstResponder()
                
                // Set up the shared UIMenuController
                let saveMenuItem = UIMenuItem(title: "Wijzig naam", action: #selector(wijzigMapnaam))
                let deleteMenuItem = UIMenuItem(title: "Verwijder", action: #selector(verwijderMap))
                UIMenuController.shared.menuItems = [saveMenuItem, deleteMenuItem]
                
                // Tell the menu controller the first responder's frame and its super view
                UIMenuController.shared.setTargetRect(senderView.frame, in: superView)
                
                // Animate the menu onto view
                UIMenuController.shared.setMenuVisible(true, animated: true)
                
            }
        }
    }
    
    @objc func wijzigMapnaam() {
        print("wijzig naam tapped")
        // ...
        // This would be a good place to optionally resign
        // responsiveView's first responder status if you need to
        //responsiveView.resignFirstResponder()
    }
    
    @objc func verwijderMap() {
        print("delete tapped")
        // ...
        //responsiveView.resignFirstResponder()
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
    
    @IBAction func mapAanmakenAnnuleren(_ sender: Any) {
        mapNaamTextfield.text = ""
        maakNieuweMapView.isHidden = true
    }
    @IBAction func mapAanmakenOpslaan(_ sender: Any) {
        let mapNaam = mapNaamTextfield.text
        do {
            try dbController.insertMap(mapNaam: mapNaam!, specialisme: gekozenSpecialisme)
            folders = createFolderArray()
            tableView.reloadData()
            mapNaamTextfield.text = ""
            maakNieuweMapView.isHidden = true
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
        }
    }
    
   
    
}
