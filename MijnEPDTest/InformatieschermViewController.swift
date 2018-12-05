//
//  InformatieschermViewController.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 06-09-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import UIKit

class InformatieschermViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollViewer: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewer.delegate = self
        // Do any additional setup after loading the view.
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
