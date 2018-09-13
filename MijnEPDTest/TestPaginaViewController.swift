//
//  TestPaginaViewController.swift
//  
//
//  Created by Denise van Diermen on 03-09-18.
//

import UIKit

class TestPaginaViewController: UIViewController {

    @IBOutlet weak var TitelVeld: UILabel!
    @IBOutlet weak var beschrijvingVeld: UILabel!
    @IBOutlet weak var datumVeld: UILabel!
    @IBOutlet weak var artsVeld: UILabel!
    @IBOutlet weak var labVeld: UILabel!
    @IBOutlet weak var specialismeVeld: UILabel!
    @IBOutlet weak var mapIDVeld: UILabel!
    
    let dbController = DatabaseConnector()
    var specialisme = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let documentGegevens = dbController.getDocumentgegevens(hetDocumentID: opgeslagenDocument)
        TitelVeld.text = "Titel: " + documentGegevens[1]
        beschrijvingVeld.text = "Beschrijving: " + documentGegevens[2]
        datumVeld.text = "Datum: " + documentGegevens[8]
        artsVeld.text = "Arts: " + documentGegevens[5]
        labVeld.text = "Onderzoek: " + documentGegevens[3]
        specialismeVeld.text = "Specialisme: " + documentGegevens[4]
        mapIDVeld.text = "MapID: " + documentGegevens[6]
        
        
        specialisme = documentGegevens[4]
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func naarSpecialismen(_ sender: Any) {
        self.performSegue(withIdentifier: "naarSpecialismen", sender: self)
        let toaster = ToastMessage()
        toaster.displayToast(message: "Het document is opgeslagen in de map 'Nieuwe documenten' onder het specialisme " + specialisme, duration: 3, viewController: self)
    }
}
