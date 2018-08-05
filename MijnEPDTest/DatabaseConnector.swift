//
//  DatabaseConnector.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 05-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation
import SQLite3
import UIKit

class DatabaseConnector {
    var databaseName = "MijnEPDDatabase.sqlite"
    var db: OpaquePointer?
    var databasePath: String
    var specialismenArray: [String]
    
    init() {
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        databasePath = dirPaths[0].appendingPathComponent(databaseName).path
        
        specialismenArray = ["Anesthesiologie", "Cardiologie", "Dermatologie", "Gynaecologie", "Huisartsgeneeskunde", "Interne geneeskunde", "Keel-neus-oorheelkunde",
                             "Kindergeneeskunde", "Klinische genetica", "Longgeneeskunde", "Maag-darm-leverziekten", "Neurologie", "Oogheelkunde", "Psychiatrie"]
        
        //controleert of de database-file al bestaat, zo niet dan worden de tabellen aangemaakt, alle specialismen geinitialiseerd en voor elk specialisme een map 'Nieuwe Documenten' aangemaakt
        if !filemgr.fileExists(atPath: databasePath as String) {
        createTables()
        initialiseerSpecialismen()
        }
    }
    
    /**
     Creeert de tabellen: SPECIALISME, MAP en MEDISCHE_DOCUMENT
     */
    func createTables() {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        else {
            let specialismeTableString = "CREATE TABLE IF NOT EXISTS SPECIALISME (S_ID TEXT PRIMARY KEY)"
            let mapTableString = "CREATE TABLE IF NOT EXISTS MAP(" +
                "MAP_ID INTEGER PRIMARY KEY, " +
                "MAP_NAAM TEXT, " +
                "SPECIALISME TEXT, " +
                "FOREIGN KEY(SPECIALISME) REFERENCES SPECIALISME(S_ID), " +
                "CONSTRAINT MAP_SPECIALISME_UNIEK UNIQUE (MAP_NAAM, SPECIALISME))"
            let documentTableString = "CREATE TABLE IF NOT EXISTS MEDISCH_DOCUMENT(" +
                "MD_ID INTEGER PRIMARY KEY, " +
                "TITEL TEXT, " +
                "BESCHRIJVING TEXT, " +
                "ONDERZOEK INTEGER, " +
                "SPECIALISME TEXT, " +
                "ARTSNAAM TEXT," +
                "MAP INTEGER, " +
                "URIFOTO TEXT, " +
                "DATUM TEXT, " +
                "FILEPATH TEXT, " +
                "FOREIGN KEY(SPECIALISME) REFERENCES SPECIALISME(S_ID), " +
            "FOREIGN KEY(MAP) REFERENCES MAP(MAP_ID))"
            
            if sqlite3_exec(db, specialismeTableString, nil, nil, nil) != SQLITE_OK {
                print("Error creating specialisme tabel")
                return
            }
            if sqlite3_exec(db, mapTableString, nil, nil, nil) != SQLITE_OK {
                print("Error creating map tabel")
                return
            }
            if sqlite3_exec(db, documentTableString, nil, nil, nil) != SQLITE_OK {
                print("Error creating document tabel")
                return
            }
            print("Alles werkt")
        }
    }
    
    /**
     Initialiseert de specialismen uit het specialismen array
    */
    func initialiseerSpecialismen() {
        for specialisme in specialismenArray {
            if sqlite3_exec(db, "INSERT INTO SPECIALISME (S_ID) VALUES ('" + specialisme + "')", nil, nil, nil) != SQLITE_OK {
                print("Error initialising specialismen in tabel")
                return
            }
        }
    }
    
    func initialiseerMappen() {
        for specialisme in specialismenArray {
            if sqlite3_exec(db, "INSERT INTO MAP (MAP_NAAM, SPECIALISME) VALUES ('Nieuwe documenten', '" + specialisme + "')", nil, nil, nil) != SQLITE_OK {
                print("Error initialising specialismen in tabel")
                return
            }
        }
    }
    
    func getSpecialismenArrayMetPlaatjes() -> [Specialism] {
        var specPlusOnderzoek = specialismenArray
        specPlusOnderzoek.insert("Medicatie", at: 0)
        specPlusOnderzoek.insert("Onderzoeken", at: 0)
        specPlusOnderzoek.insert("Bloedonderzoeken", at: 0)
        var plaatjesArray:[UIImage] = [#imageLiteral(resourceName: "bloedonderzoek_zwart"),#imageLiteral(resourceName: "onderzoek_zwart"),#imageLiteral(resourceName: "Three"),#imageLiteral(resourceName: "anesthesiologie"),#imageLiteral(resourceName: "cardiologie"),#imageLiteral(resourceName: "dermatologie"),#imageLiteral(resourceName: "gynaecologie"),#imageLiteral(resourceName: "huisartsgeneeskunde"),#imageLiteral(resourceName: "interne_geneeskunde"),#imageLiteral(resourceName: "keel_neus_oorheelkunde"),#imageLiteral(resourceName: "kindergeneeskunde"),#imageLiteral(resourceName: "klinische_genetica"),#imageLiteral(resourceName: "longgeneeskunde"),#imageLiteral(resourceName: "mdl"),#imageLiteral(resourceName: "neurologie"),#imageLiteral(resourceName: "oogheelkunde"),#imageLiteral(resourceName: "psychiatrie")]
        var specialismenMetPlaatjesArray: [Specialism] = []
        if specPlusOnderzoek.count != plaatjesArray.count {
            print("Het aantal specialismen = \(specPlusOnderzoek.count)")
            print("Het aantal plaatjes = \(plaatjesArray.count)")
            print("Het aantal plaatjes komt niet overeen met het aantal specialismen")
        }
        else {
            for i in 0...specPlusOnderzoek.count-1 {
                let specTemp = Specialism(image: plaatjesArray[i], title: specPlusOnderzoek[i])
                specialismenMetPlaatjesArray.append(specTemp)
            }
        }
        return specialismenMetPlaatjesArray
    }
    
}
