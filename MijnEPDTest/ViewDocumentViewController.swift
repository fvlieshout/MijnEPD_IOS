//
//  ViewDocumentViewController.swift
//  MijnEPDTest
//
//  Created by Miró Scholten on 09-09-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation


class ViewDocumentViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        
        let documentID = dbController.getDocumentID(docunaam: gekozenDocument, specialisme: gekozenSpecialisme, mapnaam: gekozenMap)
        let documentGegevens = dbController.getDocumentgegevens(hetDocumentID: documentID)
        titelField.text = documentGegevens[1]
        descField.text = documentGegevens[2]
        dateField.text = documentGegevens[8]
        artsField.text = documentGegevens[5]
        specialismeField.text = documentGegevens[4]
        
        
        getImage(imageId: documentGegevens[7])
        
        //fullscreen image
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(ViewDocumentViewController.imageTapped(_:)))
        imageViewer.addGestureRecognizer(pictureTap)
        imageViewer.isUserInteractionEnabled = true
        
        //Bepalen van het type onderzoek in tekst
        let typeOnderzoek = Int(documentGegevens[3])
        
        if ( typeOnderzoek == 1) {
            onderzoekField.text = "Labuitslag"
        } else if (typeOnderzoek == 3) {
            onderzoekField.text = "Röntgen foto"
        } else if (typeOnderzoek == 5) {
            onderzoekField.text = "Medicatie"
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
        delenKnop.setImage(#imageLiteral(resourceName: "Icon-Small"), for: .normal)
        self.view.addSubview(delenKnop)
        
        let editKnop = UIButton(type: .system)
        editKnop.setTitle("Bewerken", for: .normal)
        editKnop.addTarget(self, action: #selector(ViewDocumentViewController.naarBewerken), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: delenKnop), UIBarButtonItem(customView: editKnop)]
    
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
        performSegue(withIdentifier: "naarBewerken", sender: UIButton.self)
        
    }
        
        
        
        
    }
    

    
    

