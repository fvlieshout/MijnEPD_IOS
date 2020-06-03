//
//  FullscreenViewController.swift
//  MijnEPDTest
//
//  Created by Noël Bainathsah on 28/04/2019.
//  Copyright © 2019 Floor van Lieshout. All rights reserved.
//

import UIKit

class FullscreenViewController: UIViewController {
    
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.setup()
        
        imageScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        imageScrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        getImage(imageId: imageFSID)
        
        
        
        //let imageView = ImageZoomView(frame: <#T##CGRect#>, image: <#T##UIImage?#>)
    }
    
    func getImage(imageId: String){
        if (imageId == "noImageID") {
            imageScrollView.display(image: #imageLiteral(resourceName: "iosNote"))
            imageScrollView.contentMode = .scaleAspectFit
        }
        else {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageId)
        if fileManager.fileExists(atPath: imagePath){
            imageScrollView.display(image: UIImage(contentsOfFile: imagePath)!)
            
        }else{
            print("Geen afbeelding gevonden")
        }
        }
    }

}
