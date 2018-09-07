//
//  ListOfDocumentsViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 22-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

var gekozenDocument = ""
var row = 0

class ListOfDocumentsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableViewer: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var verplaatsDocumentView: UIView!
    @IBOutlet weak var contextMenuView: UIView!
    @IBOutlet weak var restOfScreenView: UIButton!
    @IBOutlet weak var pickerViewMappen: UIPickerView!
    
    var documents: [String] = []
    var data: [String] = []
    var folders: [String] = []
    let dbController = DatabaseConnector()
    let toast = ToastMessage()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationBar.title = gekozenMap
        createDocumentEnDataArray()
        folders = dbController.getMappenArray(hetGekozenSpecialisme: gekozenSpecialisme)
        verplaatsDocumentView.layer.borderColor = UIColor.black.cgColor
        verplaatsDocumentView.layer.borderWidth = 1
        addShadowToView(view: contextMenuView)
        verplaatsDocumentView.isHidden = true
        contextMenuView.isHidden = true
        restOfScreenView.isHidden = true
        pickerViewMappen.dataSource = self
        pickerViewMappen.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ListOfDocumentsViewController.handleLongPress))
        tableViewer.addGestureRecognizer(longPress)
    }
    
    /**
     Functie die wordt aangeroepen als een gebruiker lang op een map drukt
     - Parameter sender: de afzender van de longpress
     */
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: tableViewer)
            if let indexPath = tableViewer.indexPathForRow(at: touchPoint) {
                gekozenDocument = documents[indexPath.row]
                print("Geselecteerd document: " + gekozenDocument)
                
                let ycoordinaat = touchPoint.y + 70 //plaatst het pop-up menu op de plek waar geklikt is
                contextMenuView.frame.origin.y = ycoordinaat
                restOfScreenView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0) //maakt de achtergrond doorzichtig
                restOfScreenView.isHidden = false
                contextMenuView.isHidden = false //maakt het pop-up menu zichtbaar
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        folders = dbController.getMappenArray(hetGekozenSpecialisme: gekozenSpecialisme)
        return folders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return folders[row]
    }
    
    //Maakt een array aan met alle documenten (documents) en een array met alle datums van de documenten (data)
    func createDocumentEnDataArray() {
        let mapID = dbController.getMapID(mapnaam: gekozenMap, specialisme: gekozenSpecialisme)
        documents = dbController.getDocumentenArray(mapID: mapID)
        data = dbController.getDataVanDocumentenArray(mapID: mapID)
    }
    
    
    
    @IBAction func verplaatsNaarMap(_ sender: Any) {
        restOfScreenView.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.7) //maakt de achtergrond grijs zodat het pop-up menu meer opvalt
        contextMenuView.isHidden = true
        verplaatsDocumentView.isHidden = false
        restOfScreenView.isHidden = false
    }
    
    @IBAction func verwijderDocument(_ sender: Any) {
        self.contextMenuView.isHidden = true
            let alertController = UIAlertController(title: "Document verwijderen", message: "Weet u zeker dat u het document wilt verwijderen? Dit kan niet ongedaan worden gemaakt", preferredStyle: UIAlertControllerStyle.alert)
            
            let annuleerAction = UIAlertAction(title: "Annuleren", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                self.contextMenuView.isHidden = true
            }
            
            let verwijderAction = UIAlertAction(title: "Verwijder", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                self.verwijderDocumentDaadwerkelijk()
            }
            
            alertController.addAction(annuleerAction)
            alertController.addAction(verwijderAction)
            self.present(alertController, animated: true, completion: nil)
        }
    
    func verwijderDocumentDaadwerkelijk() {
        let documentID = dbController.getDocumentID(docunaam: gekozenDocument, specialisme: gekozenSpecialisme, mapnaam: gekozenMap)
        dbController.deleteDocument(hetID: documentID)
        createDocumentEnDataArray()
        tableViewer.reloadData()
    }
    
    
    @IBAction func restOfScreenTapped(_ sender: Any) {
        verplaatsDocumentView.isHidden = true
        contextMenuView.isHidden = true
        restOfScreenView.isHidden = true
    }
    
    @IBAction func opslaanWijzigenMap(_ sender: Any) {
        let nieuweMap = folders[pickerViewMappen.selectedRow(inComponent: 0)]
        let nieuweMapID = dbController.getMapID(mapnaam: nieuweMap, specialisme: gekozenSpecialisme)
        let documentID = dbController.getDocumentID(docunaam: gekozenDocument, specialisme: gekozenSpecialisme, mapnaam: gekozenMap)
        do {
            try dbController.verplaatsDocument(deDocumentTitel: gekozenDocument, hetDocumentID: documentID, hetNieuweMapID: nieuweMapID)
            toast.displayToast(message: "Het document is verplaatst naar \(gekozenSpecialisme) > \(nieuweMap)", duration: 3, viewController: self)
            verplaatsDocumentView.isHidden = true
            restOfScreenView.isHidden = true
            createDocumentEnDataArray() //haalt de vernieuwde informatie op uit de database
            tableViewer.reloadData() //refresht de TableView met de nieuwe informatie
        } catch MyError.documentBestaatAlInMapBijVerplaatsen() {
            toast.displayToast(message: "In de gekozen map bestaat al een document met dezelfde naam. De naam van het document moet eerst gewijzigd worden dat het naar deze map verplaatst kan worden", duration: 5, viewController: self)
        } catch {
            print("Unexpected error: \(error).")
            let message = "Unexpected error"
            toast.displayToast(message: message, duration: 3, viewController: self)
            verplaatsDocumentView.isHidden = true
            restOfScreenView.isHidden = true
        }
        
        
    }
    @IBAction func annulerenWijzigenMap(_ sender: Any) {
        verplaatsDocumentView.isHidden = true
        restOfScreenView.isHidden = true
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
