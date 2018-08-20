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
            if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
                print("Error opening the database")
                return
            }
            createTables()
            initialiseerSpecialismen()
            initialiseerMappen()
            if sqlite3_close(db) != SQLITE_OK {
                print("Error closing the database")
            }
        }
    }
    
    /**
     Creeert de tabellen: SPECIALISME, MAP en MEDISCHE_DOCUMENT
     */
    func createTables() {
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
    
    /**
     Maakt een array met alle specialismen uit de specialismenArray en voegt daar de bijbehorende plaatjes aan toe.
     - Returns: Een array met alle specialismen als Specialism-objecten
    */
    func getSpecialismenArrayMetPlaatjes() -> [Specialism] {
        var specPlusOnderzoek = specialismenArray
        specPlusOnderzoek.insert("Medicatie", at: 0)
        specPlusOnderzoek.insert("Onderzoeken", at: 0)
        specPlusOnderzoek.insert("Bloedonderzoeken", at: 0)
        var plaatjesArray:[UIImage] = [#imageLiteral(resourceName: "bloedonderzoek_zwart"),#imageLiteral(resourceName: "onderzoek_zwart"),#imageLiteral(resourceName: "Three"),#imageLiteral(resourceName: "anesthesiologie"),#imageLiteral(resourceName: "cardiologie"),#imageLiteral(resourceName: "dermatologie"),#imageLiteral(resourceName: "gynaecologie"),#imageLiteral(resourceName: "huisartsgeneeskunde"),#imageLiteral(resourceName: "interne_geneeskunde"),#imageLiteral(resourceName: "keel_neus_oorheelkunde"),#imageLiteral(resourceName: "kindergeneeskunde"),#imageLiteral(resourceName: "klinische_genetica"),#imageLiteral(resourceName: "longgeneeskunde"),#imageLiteral(resourceName: "mdl"),#imageLiteral(resourceName: "neurologie"),#imageLiteral(resourceName: "oogheelkunde"),#imageLiteral(resourceName: "psychiatrie")] //array met de plaatjes van alle specialismen in de juiste volgorde
        var specialismenMetPlaatjesArray: [Specialism] = []
        //controleren of het aantal plaatjes overeenkomt met het aantal specialismen
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
    
    func insertMap(mapNaam: String, specialisme: String) throws {
        
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        
        let mapID = getMapID(mapnaam: mapNaam, specialisme: specialisme)
        if (mapID == -1) {
            if sqlite3_exec(db, "INSERT INTO MAP (MAP_NAAM,SPECIALISME) VALUES ('" + mapNaam + "', '" + specialisme + "')", nil, nil, nil) != SQLITE_OK {
                print("Error initialising specialismen in tabel")
                return
        }
        }
        else {
            throw MyError.bestaandeMapError()
        }
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
    }
    
    func deleteMap(mapNaam: String, specialisme: String) {
        
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        
        let mapID = getMapID(mapnaam: mapNaam, specialisme: specialisme)
            if sqlite3_exec(db, "DELETE FROM MAP WHERE MAP_ID = \(mapID)", nil, nil, nil) != SQLITE_OK {
                print("Error deleting the folder")
                return
        }
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
    }
    
    /**
     Haalt de mappen van het gekozen specialisme op uit de database en returnt deze in een String array
     - Parameter hetGekozenSpecialisme: het specialisme waar de gebruiker op heeft geklikt
     - Returns: Een String array met de namen van de mappen in het gekozen specialisme
    */
    func getMappenArray(hetGekozenSpecialisme: String) -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var mappenArrayTemp: [String] = []
        var statement: OpaquePointer?
        let sqlString = "SELECT MAP_NAAM FROM MAP WHERE SPECIALISME = '\(hetGekozenSpecialisme)' ORDER BY MAP_NAAM"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let mapNaam = String(cString: queryResultCol1!)
            mappenArrayTemp.append(mapNaam)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return mappenArrayTemp
    }
    
    /**
     * Voegt een document toe aan de database wanneer een document wordt aangemaakt.
     *
     - Parameter titel:        de titel van het document
     - Parameter beschrijving: de beschrijving bij het document
     - Parameter onderzoek:    het type onderzoek van het document
     - Parameter hetSpecialisme:  het specialisme van het document
     - Parameter artsnaam:     de naam van de arts die vermeld staat op het document of betrokken is
     - Parameter uriFoto:      de locatie van de foto
     - Parameter datum:        de datum die wordt gegeven aan het document
     - Parameter filepath:     de locatie of het pad van het bestand
     */
    func insertDocument(titel: String, beschrijving: String, onderzoek: Int, hetSpecialisme: String, artsnaam: String, uriFoto: String, datum: String, filepath: String) {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        let insertStatementString = "INSERT INTO MEDISCH_DOCUMENT (TITEL, BESCHRIJVING, ONDERZOEK, SPECIALISME, ARTSNAAM, MAP, URIFOTO, DATUM, FILEPATH) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, titel, -1, nil)
            sqlite3_bind_text(insertStatement, 2, beschrijving, -1, nil)
            sqlite3_bind_int(insertStatement, 3, Int32(onderzoek))
            sqlite3_bind_text(insertStatement, 4, hetSpecialisme, -1, nil)
            sqlite3_bind_text(insertStatement, 5, artsnaam, -1, nil)
            let mapID = getMapID(mapnaam: "Nieuwe documenten", specialisme: hetSpecialisme)
            sqlite3_bind_int(insertStatement, 6, Int32(mapID))
            sqlite3_bind_text(insertStatement, 7, uriFoto, -1, nil)
            sqlite3_bind_text(insertStatement, 8, datum, -1, nil)
            sqlite3_bind_text(insertStatement, 9, filepath, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.") 
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
    }
    
    /**
    * Verwijdert het document uit de database.
    *
    * @param id het id van het te verwijderen document
    */
    func deleteDocument(hetID: Int) {
        
    //this.getWritableDatabase().delete("MEDISCH_DOCUMENT", "MD_ID='" + id + "'", null);
    }
    
    /**
     * Vraagt het mapID op.
     *
     * @param mapnaam     de naam de map
     * @param specialisme het specialisme waar de map bijhoort
     * @return het ID van de map in de database
     */
    func getMapID(mapnaam: String, specialisme: String) -> Int {
    var mapID = -1
    
        var statement: OpaquePointer?
        let sqlString = "SELECT MAP_ID FROM MAP WHERE (MAP_NAAM = '" + mapnaam + "' AND SPECIALISME = '" + specialisme + "')"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            mapID = Int(sqlite3_column_int(statement, 0))
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        
    return mapID;
    }
    
}
