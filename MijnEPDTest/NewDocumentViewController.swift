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
    
    
    @IBOutlet weak var titelField: UITextField!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var ArtsField: UITextField!
    
    @IBOutlet weak var labUitslag: DLRadioButton!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var documents: [String] = []
    var data: [String] = []
    var onderzoek:Int?

    let specialismen = ["Anesthesiologie", "Cardiologie", "Dermatologie", "Gynaecologie", "Huisartsgeneeskunde", "Interne geneeskunde", "Keel-neus-oorheelkunde", "Kindergeneeskunde", "Klinische genetica", "Longgeneeskunde", "Maag-darm-leverziekten", "Neurologie", "Oogheelkunde", "Psychiatrie"]
    
    let dbController = DatabaseConnector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateField.delegate = self
        locationField.delegate = self
        ArtsField.delegate = self
        descField.delegate = self
        titelField.delegate = self
        
        descField.text = "Beschrijving"
        descField.textColor = UIColor.lightGray
        
        labUitslag.isMultipleSelectionEnabled = false
        
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
    
    @IBAction func radioAction(_ sender: DLRadioButton) {
        if sender.tag == 1 {
            onderzoek = 1
        } else {
            onderzoek = 0
        }
    }

        
    @IBAction func opslaanDocument(_ sender: Any) {
        //getting values from textfields
        let beschrijving = descField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let datum = dateField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let locatie = locationField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let artsNaam = ArtsField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let titel = titelField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let specialisme = specialismen[pickerView.selectedRow(inComponent: 0)]
        
        
        
        //validating that values are not empty
        if(titel?.isEmpty)!{
            titelField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
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
        
        //Saving the document
        dbController.insertDocument(titel: titel!, beschrijving: beschrijving!, onderzoek: onderzoek!, hetSpecialisme: specialisme, artsnaam: artsNaam!, uriFoto: <#T##String#>, datum: datum!, filepath: <#T##String#>)
        
        
        
        //displaying a success message
        print("mijnEPDdocument is succesvol opgeslagen")
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
