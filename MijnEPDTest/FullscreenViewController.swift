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
            let mainImage = UIImage(contentsOfFile: imagePath)
            let rotatedImage = mainImage!.rotate(radians: .pi/2) // Rotate 90 degrees
                                
            imageScrollView.display(image: (rotatedImage)!)
            
            
        }else{
            print("Geen afbeelding gevonden")
        }
        }
    }

}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
