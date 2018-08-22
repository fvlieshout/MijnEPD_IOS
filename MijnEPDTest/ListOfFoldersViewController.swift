//
//  ListOfFoldersViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 04-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//
//  Deze viewController beschrijft het gedrag van het scherm waarop alle mappen van een specialisme worden getoond
//

import UIKit

var gekozenMap = ""

class ListOfFoldersViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var maakNieuweMapView: UIView!
    @IBOutlet weak var mapNaamTextfield: UITextField!
    @IBOutlet weak var myContextMenu: UIView!
    @IBOutlet weak var restOfScreenView: UIButton!
    @IBOutlet weak var wijzigMapnaamView: UIView!
    @IBOutlet weak var wijzigNaamTexfield: UITextField!
    
    
    var folders: [FolderClass] = []
    let dbController = DatabaseConnector()
    let toast = ToastMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maakNieuweMapView.layer.borderColor = UIColor.black.cgColor
        maakNieuweMapView.layer.borderWidth = 1
        maakNieuweMapView.isHidden = true //zet het pop-up scherm voor het aanmaken van een nieuwe map op onzichtbaar
        myContextMenu.isHidden = true //zet het pop-up menu voor het verwijderen/naam wijzigen van een map op onzichtbaar
        wijzigMapnaamView.isHidden = true //zet het pop-up scherm voor het wijzigen van de mapnaam op onzichtbaar
        addShadowToView(view: myContextMenu) //voegt schaduw toe aan het pop-up scherm om het mooier te maken
        navigationBar.title = gekozenSpecialisme
        
        folders = createFolderArray()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ListOfFoldersViewController.handleLongPress))
        tableView.addGestureRecognizer(longPress)
    }
    
    /**
     Functie die wordt aangeroepen als een gebruiker lang op een map drukt
     - Parameter sender: de afzender van de longpress
    */
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                gekozenMap = folders[indexPath.row].name
                print("Geselecteerde map: " + gekozenMap)
                
                let ycoordinaat = touchPoint.y + 70 //plaatst het pop-up menu op de plek waar geklikt is
                myContextMenu.frame.origin.y = ycoordinaat
                restOfScreenView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
                restOfScreenView.isHidden = false
                myContextMenu.isHidden = false //maakt het pop-up menu zichtbaar
            }
        }
    }
    
    /**
     Maakt een array van alle mappen van het specialisme door de mapnamen op te halen uit de database
     - Returns: een array van het type FolderClass met alle mappen van het gekozen specialisme
    */
    func createFolderArray() -> [FolderClass] {
        var tempArray: [FolderClass] = []
        let stringArray = dbController.getMappenArray(hetGekozenSpecialisme: gekozenSpecialisme)
        for map in stringArray {
            let mapje = FolderClass(name: map)
            tempArray.append(mapje)
        }
        return tempArray
    }
    
    // TODO: zorgen dat als er op een map wordt geklikt, hij naar het volgende scherm gaat
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let specialismTemp = specialisms[indexPath.row]
    //        let specialismString = specialismTemp.title
    //        self.performSegue(withIdentifier: "naarMappen", sender: self)
    //    }
    
    /**
     Wordt uitgevoerd wanneer er op de plusknop rechtsboven wordt geklikt en toont het pop-up menu waarbij een mapnaam opgegeven kan worden
     - Parameter sender: de afzender van de klik
    */
    @IBAction func maakNieuweMap(_ sender: Any) {
        mapNaamTextfield.text = ""
        maakNieuweMapView.isHidden = false
        restOfScreenView.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.7) //maakt de achtergrond grijs zodat het pop-up menu meer opvalt
        restOfScreenView.isHidden = false
    }
    
    /**
     Wordt uitgevoerd wanneer er in het 'map aanmaken' pop-up menu geklikt wordt op 'Annuleren'
     - Parameter sender: de afzender van de klik
     */
    @IBAction func mapAanmakenAnnuleren(_ sender: Any) {
        maakNieuweMapView.isHidden = true
        restOfScreenView.isHidden = true
    }
    /**
     Wordt uitgevoerd wanneer er in het 'map aanmaken' pop-up menu geklikt wordt op 'Opslaan'
     - Parameter sender: de afzender van de klik
     */
    @IBAction func mapAanmakenOpslaan(_ sender: Any) {
        let mapNaam = mapNaamTextfield.text
        do {
            try dbController.insertMap(mapNaam: mapNaam!, specialisme: gekozenSpecialisme) //voegt de nieuwe map toe aan de database
            folders = createFolderArray() //haalt de vernieuwde informatie op uit de database
            tableView.reloadData() //refresht de TableView met de nieuwe informatie
            maakNieuweMapView.isHidden = true
            restOfScreenView.isHidden = true
        } catch (MyError.bestaandeMapError()) { //controleert of de mapnaam al bestaat binnen het specialisme
            print("Map bestaat al")
            let message = "Er bestaat in dit specialisme al een map met die naam. Kies een andere naam."
            toast.displayToast(message: message, duration: 3, viewController: self)
        } catch {
            print("Unexpected error: \(error).")
            let message = "Unexpected error"
            toast.displayToast(message: message, duration: 3, viewController: self)
            maakNieuweMapView.isHidden = true
            restOfScreenView.isHidden = true
        }
    }
    
    /**
     Wordt uitgevoerd wanneer er in het context-menu geklikt wordt op 'Verwijderen'. De gebruiker wordt gevraagd om extra bevestiging
     - Parameter sender: de afzender van de klik
     */
    @IBAction func verwijderMapGeklikt(_ sender: Any) {
        self.myContextMenu.isHidden = true
        if (gekozenMap == "Nieuwe documenten") { //controleert of de gebruiker de map Nieuwe Documenten probeert te verwijderen
            let message = "Map 'Nieuwe documenten' kan niet verwijderd worden"
            toast.displayToast(message: message, duration: 3, viewController: self)
        }
        else {
        let alertController = UIAlertController(title: "Map verwijderen", message: "Weet u zeker dat u de map wilt verwijderen? Alle documenten in de map worden ook verwijderd. Dit kan niet ongedaan worden gemaakt", preferredStyle: UIAlertControllerStyle.alert)
        
        let annuleerAction = UIAlertAction(title: "Annuleren", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            self.myContextMenu.isHidden = true
        }
        
        let verwijderAction = UIAlertAction(title: "Verwijder", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            self.verwijderMap()
        }
        
        alertController.addAction(annuleerAction)
        alertController.addAction(verwijderAction)
        self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    /**
     Wordt uitgevoerd als de gebruiker na waarschuwing nog steeds de map wilt verwijderen
    */
    func verwijderMap() {
            dbController.deleteMap(mapNaam: gekozenMap, specialisme: gekozenSpecialisme)
            myContextMenu.isHidden = true
            folders = createFolderArray()
            tableView.reloadData()
    }
    
    /**
     Wordt uitgevoerd wanneer er in het context-menu geklikt wordt op 'Wijzig naam'. Toont een pop-up menu waarin de naam van de map gewijzigd kan worden
     - Parameter sender: de afzender van de klik
     */
    @IBAction func wijzigMapnaam(_ sender: Any) {
        if (gekozenMap == "Nieuwe documenten") { //controleert of de gebruiker de map Nieuwe Documenten probeert te wijzigen
            let message = "De map 'Nieuwe Documenten' kan niet gewijzigd worden"
            toast.displayToast(message: message, duration: 3, viewController: self)
        }
        else {
        wijzigNaamTexfield.text = gekozenMap
        wijzigMapnaamView.isHidden = false
        restOfScreenView.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.7) //maakt de achtergrond grijs zodat het pop-up menu meer opvalt
        restOfScreenView.isHidden = false
        }
        myContextMenu.isHidden = true
    }
    
    @IBAction func wijzigMapnaamOpslaan(_ sender: Any) {
        let nieuweNaam = wijzigNaamTexfield.text
        do {
            try dbController.updateMapNaam(oudeMapNaam: gekozenMap, specialisme: gekozenSpecialisme, nieuweMapNaam: nieuweNaam!) //voegt de nieuwe map toe aan de database
            folders = createFolderArray() //haalt de vernieuwde informatie op uit de database
            tableView.reloadData() //refresht de TableView met de nieuwe informatie
            wijzigMapnaamView.isHidden = true
            restOfScreenView.isHidden = true
        } catch (MyError.bestaandeMapError()) {
            print("Map bestaat al")
            let message = "Er bestaat in dit specialisme al een map met die naam. Kies een andere naam."
            toast.displayToast(message: message, duration: 3, viewController: self)
        } catch {
            print("Unexpected error: \(error).")
            let message = "Unexpected error"
            toast.displayToast(message: message, duration: 3, viewController: self)
            maakNieuweMapView.isHidden = true
            restOfScreenView.isHidden = true
        }
    }
    
    @IBAction func wijzigMapnaamAnnuleren(_ sender: Any) {
        wijzigMapnaamView.isHidden = true
        restOfScreenView.isHidden = true
    }
    
    /**
     Zorgt ervoor dat wanneer er buiten het 'map aanmaken' pop-up menu of buiten het context menu wordt geklikt, beide menu's vanzelf verdwijnen
     - Parameter sender: de afzender van de klik
     */
    @IBAction func restOfScreenTapped(_ sender: Any) {
        myContextMenu.isHidden = true
        maakNieuweMapView.isHidden = true
        wijzigMapnaamView.isHidden = true
        restOfScreenView.isHidden = true
        restOfScreenView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
    }
    
    /**
     Voegt schaduw toe aan de view die wordt meegegeven
     - Parameter view: de view waar schaduw aan wordt toegevoegd
     */
    private func addShadowToView (view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 6
    }
}

// De uitbreiding van de class naar UITableViewDelegate en UITableViewDataSource is in een extension geplaatst om de leesbaarheid iets te vergroten
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //beschrijft wat er moet gebeuren als er op één rij wordt geklikt
        let folderTemp = folders[indexPath.row]
        gekozenMap = folderTemp.name //hier wordt de globale variable ingesteld die dus ook in andere classes en viewControllers bereikbaar is
        self.performSegue(withIdentifier: "naarDocumenten", sender: self)
    }
}
