//
//  EditDocumentViewController.swift
//  MijnEPDTest
//
//  Created by Miró Scholten on 13-09-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation
import Foundation
import SQLite3
import UIKit


import Foundation
import SQLite3
import UIKit



class EditDocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var db: OpaquePointer?
    //outlets voor de tekstvelden en radiobutton
    
    @IBOutlet weak var titelField: UITextField!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var ArtsField: UITextField!
    @IBOutlet weak var OpslaanKnop: UIButton!
    @IBOutlet weak var labUitslag: DLRadioButton!
    
    private var datePicker: UIDatePicker?
    
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
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        
        dateField.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(NewDocumentViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        
        let documentID = dbController.getDocumentID(docunaam: gekozenDocument, specialisme: gekozenSpecialisme, mapnaam: gekozenMap)
        let documentGegevens = dbController.getDocumentgegevens(hetDocumentID: documentID)
        titelField.text = documentGegevens[1]
        descField.text = documentGegevens[2]
        dateField.text = documentGegevens[8]
        ArtsField.text = documentGegevens[5]
        
        
        getImage(imageId: documentGegevens[7])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewDocumentViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
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
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        dateField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
        
        
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
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
        let docFilePath = "filepath"
        
        let imageId = String.random()
        
        saveImage(imageId: imageId)
        
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
            try dbController.insertDocument(deTitel: docTitel!, deBeschrijving: docBeschrijving!, hetOnderzoek: docOnderzoek, hetSpecialisme: docSpecialisme, deArtsnaam: docArtsNaam!, deUriFoto: imageId, deDatum: docDatum!, deFilepath: docFilePath)
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
    
    func saveImage(imageId: String){
        //create an instance of the FileManager
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageId)
        //get the PNG data for this image
        let data = UIImagePNGRepresentation(image!)
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
        
        print("Afbeelding opgeslagen met ID: " + imageId)
    }
    
    func getImage(imageId: String){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageId)
        if fileManager.fileExists(atPath: imagePath){
            imageViewer.image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Geen afbeelding gevonden")
        }
    }
    
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
    
    //Bij het drukken op de cameraknop wordt er een IOS actiosheet geopend die de opties geeft voor het kiezen van een foto uit de foto bibliotheek of de camera opent
    
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
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        imageViewer.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

//Zorgt ervoor dat de return knop in het keyboard naar behoren werkt

extension EditDocumentViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}












