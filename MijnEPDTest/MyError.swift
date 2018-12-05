//
//  MyError.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 06-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//
//  Class beschrijft alle custom errors die kunnen worden gemaakt en teruggegeven aan een ViewController

import Foundation
enum MyError: Error {
    case bestaandeMapError()
    case wijzigMapNieuweDocumentenError()
    case verwijderMapNieuweDocumentenError()
    case documentBestaatAlInMapBijVerplaatsen()
    case documentBestaatAlInMapBijAanmaken()
}
