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
    override func viewDidLoad() {
        super.viewDidLoad()
        let documentGegevens = dbController.getDocumentgegevens(hetDocumentID: opgeslagenDocument)
        TitelVeld.text = documentGegevens[0]
        beschrijvingVeld.text = documentGegevens[1]
        datumVeld.text = documentGegevens[6]
        artsVeld.text = documentGegevens[4]
        labVeld.text = documentGegevens[2]
        specialismeVeld.text = documentGegevens[3]
        mapIDVeld.text = documentGegevens[8]
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

}
