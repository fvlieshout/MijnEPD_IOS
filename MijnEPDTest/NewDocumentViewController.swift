//
//  NewDocumentViewController.swift
//  MijnEPDTest
//
//  Created by Noel Bainathsah on 14-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation
import SQLite3
import UIKit

var opgeslagenDocument = -1
var docOnderzoek = 0
var image:UIImage? = nil
var imagePath:String = ""

class NewDocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var db: OpaquePointer?
    //outlets voor de tekstvelden en radiobutton
    
    @IBOutlet weak var titelField: UITextField!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var ArtsField: UITextField!
    @IBOutlet weak var OpslaanKnop: UIButton!
    @IBOutlet weak var specialisme: UITextField!
    @IBOutlet weak var labUitslag: DLRadioButton!
    
    private var datePicker: UIDatePicker?
    private var docTitel: String?
    private var docBeschrijving: String?
    private var docSpecialisme: String?
    private var docDatum: String?
    private var docArtsNaam: String?
    private var docFilePath: String?
    
    private var gekozenSpecialisme: String?
    
    var imageId = String.random()
    
    @IBOutlet weak var label: UILabel!
    
    let dbController = DatabaseConnector()
    var specialismen: [String] = []
    var toast = ToastMessage()
    var ingesteldeDatum = Date()
    var pickerView = UIPickerView()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        specialismen = dbController.getSpecialismenArray()
        dateField.delegate = self
        ArtsField.delegate = self
        descField.delegate = self
        titelField.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        descField.text = "Beschrijving"
        descField.textColor = UIColor.lightGray
        
        labUitslag.isMultipleSelectionEnabled = false
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.locale = nederlands
        //method om datepicker met 'Klaar' en 'Cancel' knoppen te tonen
        self.showDatePicker()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewDocumentViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        specialisme.inputView = pickerView
        
        pickerView.backgroundColor = .white
        pickerView.showsSelectionIndicator = true
        
        //added an empty value to the beginning of the specialism array to prevent the pickerview value chosen being empty but still being on the anesthesiology row.
        specialismen.insert("", at: 0)

        
        //Voegt een toolbar toe aan de pickerview om cancel en klaarknoppen te plaatsen.
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()


        let pickerDoneButton = UIBarButtonItem(title: "Klaar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Annuleren", style: UIBarButtonItemStyle.plain, target: self, action: #selector(annuleerPicker(_:)))

        toolBar.setItems([cancelButton, spaceButton, pickerDoneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        specialisme.inputAccessoryView = toolBar
        
        
        
    }
    
    //Specialisme pickerview setup
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return specialismen[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specialismen.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gekozenSpecialisme = specialismen[row]
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
    
    @objc func donePicker(_ sender: UIBarButtonItem){
        specialisme.text = gekozenSpecialisme
        specialisme.resignFirstResponder()
    }
    
    @objc func annuleerPicker(_ sender: UIBarButtonItem){
        specialisme.text = ""
        specialisme.resignFirstResponder()
    }
   
    
    
    
    
    
    @IBAction func opslaanInfo(_ sender: Any) {
        //getting values from textfields
        docTitel = titelField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        docBeschrijving = descField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        docSpecialisme = specialismen[pickerView.selectedRow(inComponent: 0)]
        docDatum = dateField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        docArtsNaam = ArtsField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        docFilePath = "filepath"
    
        imageId = String.random()
        
        //validating that values are not empty
        if(docTitel ?? "").isEmpty{
            let alertController = UIAlertController(title: "Fout:", message:
                "Voeg een titel toe", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if(docDatum == "") {
            dateField.layer.borderWidth = CGFloat(Float(1.0))
            dateField.layer.cornerRadius = CGFloat(Float(5.0))
            dateField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(imageViewer.image == nil) {
            
            let alertController = UIAlertController(title: "Geen afbeelding gelecteerd", message:
                "Weet u zeker dat u geen afbeelding wilt selecteren. Afbeeldingen kunnen niet later nog worden toegevoegd. In dit geval zal het document als notitie worden opgeslagen", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: { (action) in alertController.dismiss(animated: true, completion: nil)
                return
                }))
            alertController.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.default, handler: { (action) in alertController.dismiss(animated: true, completion: nil)
                print("geklikt op ja")
                self.restOpslaan()
                }))
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            restOpslaan()
        }
    }
    
    func restOpslaan() -> Void {
        if (imageViewer.image != nil)
        {
            self.saveImage(imageId: imageId)
        }
        else {
            imageId = "noImageID"
        }
        
        //Controleert of het onderzoek een unieke naam heeft
        
        if (docOnderzoek == 1 || docOnderzoek == 3 || docOnderzoek == 5) {
            if (dbController.nameExists(deDocumentTitel: docTitel!, hetDocumentID: -1)) {
                toast.displayToast(message: "Alle labuitslagen en (röntgen)onderzoeken moeten een unieke titel hebben. Er zijn meerdere onderzoeken met dezelde titel, geef deze een unieke titel.", duration: 3, viewController: self)
                return
            }
        }
        
        
        do {
            try dbController.insertDocument(deTitel: docTitel!, deBeschrijving: docBeschrijving!, hetOnderzoek: docOnderzoek, hetSpecialisme: docSpecialisme!, deArtsnaam: docArtsNaam!, deUriFoto: imageId, deDatum: docDatum!, deFilepath: docFilePath!)
            //emptying the textfields
            descField.text=""
            dateField.text=""
            ArtsField.text=""
            
            
            //displaying a success message
            print("mijnEPDdocument is succesvol opgeslagen")
          
            opgeslagenDocument = dbController.getDocumentID(docunaam: docTitel!, specialisme: docSpecialisme!, mapnaam: "Nieuwe documenten")
            self.performSegue(withIdentifier: "naarMenu", sender: self)
            let toaster = ToastMessage()
            toaster.displayToast(message: "Het document is opgeslagen in de map 'Nieuwe documenten' onder het specialisme " + docSpecialisme!, duration: 3, viewController: self)
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
    
    func showDatePicker(){
        datePicker?.setDate(ingesteldeDatum, animated: true)
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        // add toolbar to textField
        dateField.inputAccessoryView = toolbar
        // add datepicker to textField
        dateField.inputView = datePicker
        
        
    }
    
    @objc func donedatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateField.text = formatter.string(from: datePicker!.date)
        ingesteldeDatum = datePicker!.date
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
        datePicker?.setDate(ingesteldeDatum, animated: true)
    }
}

//Zorgt ervoor dat de return knop in het keyboard naar behoren werkt

extension NewDocumentViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

/**
 Genereert een random imageID zodat elke afbeelding zijn eigen unieke naam heeft.
 - Returns: Een random string van 20 characters
 */
extension String {
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

