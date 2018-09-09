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

var opgeslagenDocument = -1
var docOnderzoek = 0

class NewDocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var db: OpaquePointer?
    //outlets voor de tekstvelden en radiobutton
    
    @IBOutlet weak var titelField: UITextField!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var ArtsField: UITextField!
    @IBOutlet weak var OpslaanKnop: UIButton!
    @IBOutlet weak var labUitslag: DLRadioButton!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let dbController = DatabaseConnector()
    var specialismen: [String] = []
    var toast = ToastMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        specialismen = dbController.getSpecialismenArray()
        dateField.delegate = self
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
    
    
    @IBAction func radioButton(_ sender: DLRadioButton) {
        
        if (sender.tag == 0) {
                docOnderzoek = 0
            } else if (sender.tag == 1) {
                docOnderzoek = 1
            } else if (sender.tag == 2) {
                docOnderzoek = 2
            } else if (sender.tag == 3) {
                docOnderzoek = 3
            } else if (sender.tag == 4) {
                docOnderzoek = 4
            } else if (sender.tag == 5) {
                docOnderzoek = 5
        }
    }
    
    
    
    @IBAction func opslaanInfo(_ sender: Any) {
        //getting values from textfields
        let docTitel = titelField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let docBeschrijving = descField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let docSpecialisme = specialismen[pickerView.selectedRow(inComponent: 0)]
        let docDatum = dateField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let docArtsNaam = ArtsField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let docUriFoto = "Urifoto"
        let docFilePath = "filepath"
        
        //validating that values are not empty
        if(docBeschrijving?.isEmpty)!{
            descField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(docDatum?.isEmpty)!{
            dateField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(docArtsNaam?.isEmpty)!{
            ArtsField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        do {
            try dbController.insertDocument(deTitel: docTitel!, deBeschrijving: docBeschrijving!, hetOnderzoek: docOnderzoek, hetSpecialisme: docSpecialisme, deArtsnaam: docArtsNaam!, deUriFoto: docUriFoto, deDatum: docDatum!, deFilepath: docFilePath)
            //emptying the textfields
            descField.text=""
            dateField.text=""
            ArtsField.text=""
            
            
            //displaying a success message
            print("mijnEPDdocument is succesvol opgeslagen")
            opgeslagenDocument = dbController.getDocumentID(docunaam: docTitel!, specialisme: docSpecialisme, mapnaam: "Nieuwe documenten")
            self.performSegue(withIdentifier: "testSegue", sender: self)
        } catch MyError.documentBestaatAlInMapBijAanmaken() {
            toast.displayToast(message: "Er bestaat in de map 'Nieuwe documenten' van dit specialisme al een document met deze titel. Kies een andere titel", duration: 4, viewController: self)
        } catch {
            print("Unexpected error: \(error).")
            let message = "Unexpected error"
            toast.displayToast(message: message, duration: 3, viewController: self)
        }
    }
    
//    @IBAction func radioAction(_ sender: DLRadioButton) {
//        if sender.tag == 1 {
//            print("Het is een labuitslag")
//        } else {
//            print("Het is geen labuitslag")
//        }
//    }
    
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
