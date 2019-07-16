//
//  ViewDocumentViewController.swift
//  MijnEPDTest
//
//  Created by Noel Bainathsah on 09-09-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation
import MessageUI

var onderzoek = false
var documentIDEdit = -1

class ViewDocumentViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    //outlets voor de tekstvelden en radiobutton
    @IBOutlet weak var titelField: UITextField!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var artsField: UITextField!
    @IBOutlet weak var onderzoekField: UITextField!
    @IBOutlet weak var specialismeField: UITextField!
    @IBOutlet weak var editKnop: UIBarButtonItem!
    @IBOutlet weak var delenKnop: UIBarButtonItem!
    
    let dbController = DatabaseConnector()
    var specialisme = ""
    var segueData: String?
    var documentID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        if (segueData == "Onderzoek") {
            onderzoek = true
            documentID = dbController.getDocumentIDOnderzoek(docunaam: gekozenDocument)
        }
        else {
            onderzoek = false
        documentID = dbController.getDocumentID(docunaam: gekozenDocument, specialisme: gekozenSpecialisme, mapnaam: gekozenMap)
        }
        let documentGegevens = dbController.getDocumentgegevens(hetDocumentID: documentID!)
        titelField.text = documentGegevens[1]
        descField.text = documentGegevens[2]
        dateField.text = documentGegevens[8]
        artsField.text = documentGegevens[5]
        specialismeField.text = documentGegevens[4]
        getImage(imageId: documentGegevens[7])
        
        titelField.isUserInteractionEnabled = false
        descField.isUserInteractionEnabled = false
        dateField.isUserInteractionEnabled = false
        artsField.isUserInteractionEnabled = false
        specialismeField.isUserInteractionEnabled = false
        
        //fullscreen image
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(ViewDocumentViewController.imageTapped(_:)))
        imageViewer.addGestureRecognizer(pictureTap)
        imageViewer.isUserInteractionEnabled = true
        
        //Bepalen van het type onderzoek in tekst
        let typeOnderzoek = Int(documentGegevens[3])
        
        if ( typeOnderzoek == 1) {
            onderzoekField.text = "Labuitslag"
        } else if (typeOnderzoek == 3) {
            onderzoekField.text = "Röntgenfoto"
        } else if (typeOnderzoek == 5) {
            onderzoekField.text = "Medicatie"
        } else {
            onderzoekField.text = "Anders"
        }
        
        //        Volgorde van de velden
        //        documentID = 0
        //        titel = 1
        //        beschrijving = 2
        //        onderzoek = 3
        //        specialisme = 4
        //        artsnaam = 5
        //        mapID = 6
        //        fotouri = 7
        //        datum = 8
        //        filepath = 9
        
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationBarItems(){
        
        let delenKnop = UIButton(type: .system)
        delenKnop.setImage(#imageLiteral(resourceName: "ShareNew"), for: .normal)
        self.view.addSubview(delenKnop)
        delenKnop.addTarget(self, action: #selector(sendMail), for: UIControlEvents.touchUpInside)
        
        let editKnop = UIButton(type: .system)
        editKnop.setTitle("Bewerken", for: .normal)
        editKnop.addTarget(self, action: #selector(ViewDocumentViewController.naarBewerken), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: delenKnop), UIBarButtonItem(customView: editKnop)]
    
    }
    
    @objc func sendMail() {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
        
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
        mailComposerVC.setToRecipients(["sjpinto@gmail.com"])
        mailComposerVC.setSubject("mijnEPD help plus UW NAAM")
        mailComposerVC.setMessageBody("", isHTML: false)
        let imageData = UIImagePNGRepresentation(imageViewer.image!)! as NSData
        mailComposerVC.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName.png")
        self.present(mailComposerVC, animated: true, completion: nil)
        
        return mailComposerVC
    }
    
    func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: "Email kan niet worden verzonden", message: "MijnEPD heeft een probleem ervaren met het verzenden van uw bericht", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    private func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func getImage(imageId: String){
        if (imageId == "noImageID") {
            imageViewer.image = #imageLiteral(resourceName: "iosNote")
            imageViewer.contentMode = .scaleAspectFit
        }
        else {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageId)
        if fileManager.fileExists(atPath: imagePath){
            imageViewer.image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Geen afbeelding gevonden")
        }
        }
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
        
    @objc func naarBewerken(){
        documentIDEdit = documentID!
        performSegue(withIdentifier: "naarBewerken", sender: UIButton.self)
        
    }
        
        
        
        
    }
    

    
    

