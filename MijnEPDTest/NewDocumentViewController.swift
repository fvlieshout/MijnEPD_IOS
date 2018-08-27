//
//  NewDocumentViewController.swift
//  MijnEPDTest
//
//  Created by Miró Scholten on 14-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation
import SQLite3
import UIKit

class NewDocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var db: OpaquePointer?
    //outlets voor de tekstvelden en radiobutton
    
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var ArtsField: UITextField!
    
    @IBOutlet weak var labUitslag: DLRadioButton!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let specialismen = ["Anesthesiologie", "Cardiologie", "Dermatologie", "Gynaecologie", "Huisartsgeneeskunde", "Interne geneeskunde", "Keel-neus-oorheelkunde",
                        "Kindergeneeskunde", "Klinische genetica", "Longgeneeskunde", "Maag-darm-leverziekten", "Neurologie", "Oogheelkunde", "Psychiatrie"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateField.delegate = self
        locationField.delegate = self
        ArtsField.delegate = self
        descField.delegate = self
        
        
        descField.text = "Beschrijving"
        descField.textColor = UIColor.lightGray
        
        labUitslag.isMultipleSelectionEnabled = false
        DatabaseConnector.init()
        
}
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return specialismen[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specialismen.count
    }
    
    @IBAction func opslaanInfo(_ sender: UIButton) {
        //getting values from textfields
        let beschrijving = descField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let datum = dateField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let locatie = locationField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let artsNaam = ArtsField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //validating that values are not empty
        if(beschrijving?.isEmpty)!{
            descField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(datum?.isEmpty)!{
            dateField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(locatie?.isEmpty)!{
            locationField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(artsNaam?.isEmpty)!{
            ArtsField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        
        
    
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO mijnEPD (beschrijving, datum, locatie, artsNaam) VALUES (?,?,?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, beschrijving, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding beschrijving: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, (datum! as NSString).intValue) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding datum: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, locatie, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding locatie: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, artsNaam, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding Artsnaam: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting mijnEPDdocumnent: \(errmsg)")
            return
        }
        
        //emptying the textfields
        descField.text=""
        dateField.text=""
        locationField.text=""
        ArtsField.text=""
        
        
        //displaying a success message
        print("mijnEPDdocument is succesvol opgeslagen")
        
    }
    
    @IBAction func radioAction(_ sender: DLRadioButton) {
        if sender.tag == 1 {
            print("Het is een labuitslag")
        } else {
            print("Het is geen labuitslag")
        }
    }
    
    //Mark:- UITextViewDelegates
    //Zorgt voor een placeholder text binnen het beschrijving vak, textview ondersteund dit namelijk native niet.
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descField.text == "Beschrijving" {
            descField.text = ""
            descField.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            descField.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descField.text == "" {
        descField.text = "Beschrijving"
        descField.textColor = UIColor.lightGray
        }
    }
    
    //Bij het drukken op de cameraknop wordt er een IOS actiosheet geopend die de opties geeft voor het kiezen van een foto uit de foto bibliotheek of de camera opend
    
    @IBAction func openCamera(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                    let alertController = UIAlertController(title: "mijnEPD", message:
                        "Camera is niet beschikbaar", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            
           
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Foto Bibliotheek", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageViewer.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    
}

//Zorgt ervoor dat de return knop in het keyboard naar behoren werkt

extension NewDocumentViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
