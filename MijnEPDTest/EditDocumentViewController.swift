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
    @IBOutlet weak var rontgenbutton: DLRadioButton!
    @IBOutlet weak var medicatiebutton: DLRadioButton!
    @IBOutlet weak var anderbutton: DLRadioButton!
    
    
    private var datePicker: UIDatePicker?
    private var documentID: Int?
    private var nieuwMapID: Int?
    private var origineleMapID: Int?
    private var origineleSpecialisme: String?
    private var onderzoek: Int?
    private var ingesteldeDatum: Date?
    
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
        
        labUitslag.isMultipleSelectionEnabled = false
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.locale = nederlands
        
        
        documentID = documentIDEdit
        let documentGegevens = dbController.getDocumentgegevens(hetDocumentID: documentID!)
        
        origineleMapID = dbController.getMapIDmetDocuID(hetDocuID: documentID!)
        titelField.text = documentGegevens[1]
        descField.text = documentGegevens[2]
        dateField.text = documentGegevens[8]
        ArtsField.text = documentGegevens[5]
        origineleSpecialisme = documentGegevens[4]
        pickerView.selectRow(specialismen.index(of: origineleSpecialisme!) ?? 0, inComponent: 0, animated: true)
        getImage(imageId: documentGegevens[7])
        
        onderzoek = Int(documentGegevens[3])
        if (onderzoek == 1) {
            labUitslag.isSelected = true
        }
        else if (onderzoek == 3) {
            rontgenbutton.isSelected = true
        }
        else if (onderzoek == 5) {
            medicatiebutton.isSelected = true
        }
        else {
            anderbutton.isSelected = true
        }
        
        //method om datepicker met 'Klaar' en 'Cancel' knoppen te tonen
        self.showDatePicker()
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
        //let docFilePath = "filepath"
        
        //let imageId = String.random()
        
        //saveImage(imageId: imageId)
        
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
        
        //Controleert of het onderzoek een unieke naam heeft
        if (docOnderzoek == 1 || docOnderzoek == 3 || docOnderzoek == 5) {
            if (dbController.nameExists(deDocumentTitel: docTitel!, hetDocumentID: documentID!)) {
                toast.displayToast(message: "Alle labuitslagen en (röntgen)onderzoeken moeten een unieke titel hebben. Er zijn meerdere onderzoeken met dezelde titel, geef deze een unieke titel.", duration: 3, viewController: self)
                return
            }
        }
        
        do {
            if (docSpecialisme == origineleSpecialisme) {
                nieuwMapID = origineleMapID
                print(nieuwMapID!)
            }
            else {
                nieuwMapID = dbController.getMapID(mapnaam: "Nieuwe documenten", specialisme: docSpecialisme)
            }
            try dbController.updateDocument(hetID: documentID!, deTitel: docTitel!, deBeschrijving: docBeschrijving!, hetOnderzoek: docOnderzoek, hetSpecialisme: docSpecialisme, deArtsnaam: docArtsNaam!, hetMapID: nieuwMapID!, deDatum: docDatum!)
            
            //emptying the textfields
            descField.text=""
            dateField.text=""
            ArtsField.text=""
            
            
            //displaying a success message
            print("mijnEPDdocument is succesvol opgeslagen")
            opgeslagenDocument = documentID!
            self.performSegue(withIdentifier: "naarMenu", sender: self)
            let toaster = ToastMessage()
            toaster.displayToast(message: "De wijzigingen zijn succesvol opgeslagen", duration: 3, viewController: self)

        } catch MyError.documentBestaatAlInMapBijAanmaken() {
            toast.displayToast(message: "Er bestaat in de map 'Nieuwe documenten' van dit specialisme al een document met deze titel. Kies een andere titel", duration: 4, viewController: self)
        } catch {
            print("Unexpected error: \(error).")
            let message = "Unexpected error"
            toast.displayToast(message: message, duration: 3, viewController: self)
        }
    }
    
//    func saveImage(imageId: String){
//        //create an instance of the FileManager
//        let fileManager = FileManager.default
//        //get the image path
//        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageId)
//        //get the PNG data for this image
//        let data = UIImagePNGRepresentation(image!)
//        //store it in the document directory
//        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
//
//        print("Afbeelding opgeslagen met ID: " + imageId)
//    }
    
    func getImage(imageId: String){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageId)
        if fileManager.fileExists(atPath: imagePath){
            imageViewer.transform = imageViewer.transform.rotated(by: .pi / 2)
            imageViewer.image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Geen afbeelding gevonden")
        }
    }
    
    //Zorgt voor een placeholder text binnen het beschrijving vak, textview ondersteunt dit namelijk native niet.
    
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
    
    func showDatePicker(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        //according to date format your date string
        print(dateField.text!)
        guard let pickerDatum = dateFormatter.date(from: dateField.text!) else {
            return
        }
        ingesteldeDatum = pickerDatum
        datePicker?.setDate(ingesteldeDatum!, animated: true)
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
        datePicker?.setDate(ingesteldeDatum!, animated: true)
    }
}

//Zorgt ervoor dat de return knop in het keyboard naar behoren werkt

extension EditDocumentViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}












