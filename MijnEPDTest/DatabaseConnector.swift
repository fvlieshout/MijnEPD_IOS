//
//  DatabaseConnector.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 05-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//
//  Class die alle communicatie met de database regelt
//

import Foundation
import SQLite3
import UIKit

class DatabaseConnector {
    var databaseName = "MijnEPDDatabase.sqlite"
    var db: OpaquePointer?
    var databasePath: String
    var specialismenArray: [String]
    let nieuweMap = "Nieuwe documenten"
    
    init() {
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory,
                                    in: .userDomainMask) //plaatst de database in de documentDirectory van de FileManager
        
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
     Let op: als je hier iets in wilt veranderen, moet je vervolgens eerst de data van de Simulator verwijderen via Hardware > Erase all data and settings, anders wordt de database niet goed opnieuw aangemaakt
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
    
    /**
     Initialiseert voor elk specialisme de map 'Nieuwe documenten'
     */
    func initialiseerMappen() {
        for specialisme in specialismenArray {
            if sqlite3_exec(db, "INSERT INTO MAP (MAP_NAAM, SPECIALISME) VALUES ('Nieuwe documenten', '" + specialisme + "')", nil, nil, nil) != SQLITE_OK {
                print("Error initialising specialismen in tabel")
                return
            }
        }
    }
    
    /**
     Return de array met de namen van alle specialismen
     - Returns: String array met de namen van alle specialismen
     */
    func getSpecialismenArray() -> [String] {
        return specialismenArray
    }
    
    /**
     Maakt een array met alle specialismen uit de specialismenArray en voegt daar de bijbehorende plaatjes aan toe.
     - Returns: Een array met alle specialismen als Specialism-objecten
     */
    func getSpecialismenArrayMetPlaatjes() -> [Specialism] {
        var specPlusOnderzoek = specialismenArray
        specPlusOnderzoek.insert("Medicatie", at: 0)
        specPlusOnderzoek.insert("Rontgen Onderzoeken", at: 0)
        specPlusOnderzoek.insert("Labuitslagen", at: 0)
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
    
    /**
     Voegt een map toe aan de database met het juiste specialisme
     Wanneer de map al bestaat in dat specialisme, wordt een 'bestaandeMapError' gecreeerd
     - Parameter mapNaam: de naam van de nieuwe map
     - Parameter specialisme: het specialisme waarbinnen de map is toegevoegd
     */
    func insertMap(mapNaam: String, specialisme: String) throws {
        let mapID = getMapID(mapnaam: mapNaam, specialisme: specialisme)
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        if (mapID == -1) { //wanneer het mapID gelijk is aan -1, bestaat de map nog niet binnen dat specialisme
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
    
    /**
     Verwijdert een map uit de database
     - Parameter mapNaam: de naam van de map die verwijderd moet worden
     - Parameter specialisme: het specialisme waar de map zich in bevindt
     */
    func deleteMap(mapNaam: String, specialisme: String) {
        let mapID = getMapID(mapnaam: mapNaam, specialisme: specialisme)
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        if sqlite3_exec(db, "DELETE FROM MAP WHERE MAP_ID = \(mapID)", nil, nil, nil) != SQLITE_OK {
            print("Error deleting the folder")
            return
        }
        
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
    }
    
    /**
     Wijzigt de naam van de map in de database
     - Parameter oudeMapNaam: de oude naam van de map
     - Parameter specialisme: het specialisme waar de map zich in bevindt
     - Parameter nieuweMapNaam: de nieuwe naam van de map
     */
    func updateMapNaam(oudeMapNaam: String, specialisme: String, nieuweMapNaam: String) throws {
        
        let mapID = getMapID(mapnaam: oudeMapNaam, specialisme: specialisme)
        let nieuwMapID = getMapID(mapnaam: nieuweMapNaam, specialisme: specialisme)
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        if (nieuwMapID == -1) { //wanneer nieuwMapID gelijk is aan -1, bestaat de nieuwe map nog niet binnen dat specialisme
            if sqlite3_exec(db, "UPDATE MAP SET MAP_NAAM = '" + nieuweMapNaam + "' WHERE MAP_ID = \(mapID)", nil, nil, nil) != SQLITE_OK {
                print("Error updating the folder")
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
        var statement: OpaquePointer? = nil
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
    func insertDocument(deTitel: String, deBeschrijving: String, hetOnderzoek: Int, hetSpecialisme: String, deArtsnaam: String, deUriFoto: String, deDatum: String, deFilepath: String) throws {
        let mapID = getMapID(mapnaam: nieuweMap, specialisme: hetSpecialisme)
        // controleren of er al een document bestaat in die map met deze naam
        let documentenArrayUitMap = getDocumentenArray(mapID: mapID)
        if documentenArrayUitMap.contains(deTitel) {
            throw MyError.documentBestaatAlInMapBijAanmaken()
        }
        
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        
        if sqlite3_exec(db, "INSERT INTO MEDISCH_DOCUMENT (TITEL, BESCHRIJVING, ONDERZOEK, SPECIALISME, ARTSNAAM, MAP, URIFOTO, DATUM, FILEPATH) VALUES ('\(deTitel)', '\(deBeschrijving)', '\(hetOnderzoek)', '\(hetSpecialisme)', '\(deArtsnaam)', '\(mapID)', '\(deUriFoto)', '\(deDatum)', '\(deFilepath)')", nil, nil, nil) != SQLITE_OK {
            print("Error initialising specialismen in tabel")
            return
        }
        
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
    }
    
    
    /**
     Verwijdert het document uit de database.
     - Parameter hetID: het id van het te verwijderen document
     */
    func deleteDocument(hetID: Int) {
        
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        if sqlite3_exec(db, "DELETE FROM MEDISCH_DOCUMENT WHERE MD_ID = \(hetID)", nil, nil, nil) != SQLITE_OK {
            print("Error deleting the document")
            return
        }
        
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
    }

    func verplaatsDocument(deDocumentTitel: String, hetDocumentID: Int, hetNieuweMapID: Int) throws {
        // controleren of er al een document bestaat in die map met deze naam
        let documentenArrayUitMap = getDocumentenArray(mapID: hetNieuweMapID)
        if documentenArrayUitMap.contains(deDocumentTitel) {
            throw MyError.documentBestaatAlInMapBijVerplaatsen()
        }
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return
        }
        if sqlite3_exec(db, "UPDATE MEDISCH_DOCUMENT SET MAP = \(hetNieuweMapID) WHERE MD_ID = \(hetDocumentID)", nil, nil, nil) != SQLITE_OK {
            print("Error updating the folder")
            return
        }
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
    }
    
    //    public void verplaatsDocument(int documentID, int nieuweMapID) {
    //    SQLiteDatabase db = getWritableDatabase();
    //    db.execSQL("UPDATE MEDISCH_DOCUMENT SET MAP = " + nieuweMapID + " WHERE MD_ID = " + documentID);
    //    }
    
    /**
     Haalt de documenten van de gekozen map op uit de database en returnt deze in een String array
     - Parameter mapID: de map waar de gebruiker op heeft geklikt
     - Returns: Een String array met de namen van de documenten in de gekozen map
     */
    func getDocumentenArray(mapID: Int) -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var documentenArrayTemp: [String] = []
        var statement: OpaquePointer? = nil
        let sqlString = "SELECT TITEL FROM MEDISCH_DOCUMENT WHERE MAP = \(mapID) ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let documentNaam = String(cString: queryResultCol1!)
            documentenArrayTemp.append(documentNaam)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return documentenArrayTemp
    }
    
    /**
     Haalt de data van de documenten van de gekozen map op uit de database en returnt deze in een String array
     - Parameter mapID: de map waar de gebruiker op heeft geklikt
     - Returns: Een String array met de data van de documenten in de gekozen map
     */
    func getDataVanDocumentenArray(mapID: Int) -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var documentenArrayTemp: [String] = []
        var statement: OpaquePointer?
        let sqlString = "SELECT DATUM FROM MEDISCH_DOCUMENT WHERE (MAP = \(mapID)) ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let docuDatum = String(cString: queryResultCol1!)
            documentenArrayTemp.append(docuDatum)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return documentenArrayTemp
    }
    
    /**
     Haalt de documenten van de labuitslagen uit de database en returnt deze in een String array
     - Returns: Een String array met de documenten van de labuitslagen
     */
    
    func getLabuitslagenDocumentenArray() -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var labuitslagenDocumentenArray: [String] = []
        var statement: OpaquePointer? = nil
        let sqlString = "SELECT TITEL FROM MEDISCH_DOCUMENT WHERE ONDERZOEK = 1 ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let documentNaam = String(cString: queryResultCol1!)
            labuitslagenDocumentenArray.append(documentNaam)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return labuitslagenDocumentenArray
    }
    
    /**
     Haalt de data van de labuitslagen uit de database en returnt deze in een String array
     - Returns: Een String array met de documenten van de labuitslagen
     */
    
    func getDataLabuitslagenDocumentenArray() -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var dataLabuitslagenDocumentenArrayTemp: [String] = []
        var statement: OpaquePointer?
        let sqlString = "SELECT TITEL FROM MEDISCH_DOCUMENT WHERE ONDERZOEK = 1 ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let docuDatum = String(cString: queryResultCol1!)
            dataLabuitslagenDocumentenArrayTemp.append(docuDatum)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return dataLabuitslagenDocumentenArrayTemp
    }
    
    /**
     Haalt de documenten van de rontgenuitslagen uit de database en returnt deze in een String array
     - Returns: Een String array met de documenten van de labuitslagen
     */
    
    func getRontgenDocumentenArray() -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var rontgenDocumentenArray: [String] = []
        var statement: OpaquePointer? = nil
        let sqlString = "SELECT TITEL FROM MEDISCH_DOCUMENT WHERE ONDERZOEK = 3 ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let documentNaam = String(cString: queryResultCol1!)
            rontgenDocumentenArray.append(documentNaam)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return rontgenDocumentenArray
    }
    
    /**
     Haalt de data van de rontgenuitslagen uit de database en returnt deze in een String array
     - Returns: Een String array met de documenten van de labuitslagen
     */
    
    func getDataRontgenDocumentenArray() -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var dataRontgenDocumentenArrayTemp: [String] = []
        var statement: OpaquePointer?
        let sqlString = "SELECT TITEL FROM MEDISCH_DOCUMENT WHERE ONDERZOEK = 3 ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let docuDatum = String(cString: queryResultCol1!)
            dataRontgenDocumentenArrayTemp.append(docuDatum)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return dataRontgenDocumentenArrayTemp
    }
    
    /**
     Haalt de documenten van de medicatie uit de database en returnt deze in een String array
     - Returns: Een String array met de documenten van de medicatie
     */
    
    func getMedicatieDocumentenArray() -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var medicatieDocumentenArray: [String] = []
        var statement: OpaquePointer? = nil
        let sqlString = "SELECT TITEL FROM MEDISCH_DOCUMENT WHERE ONDERZOEK = 5 ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let documentNaam = String(cString: queryResultCol1!)
            medicatieDocumentenArray.append(documentNaam)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return medicatieDocumentenArray
    }
    
    /**
     Haalt de data van de medicatieDocumenten uit de database en returnt deze in een String array
     - Returns: Een String array met de documenten van de medicatie
     */
    
    func getDataMedicatieDocumentenArray() -> [String] {
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return []
        }
        var dataMedicatieDocumentenArrayTemp: [String] = []
        var statement: OpaquePointer?
        let sqlString = "SELECT TITEL FROM MEDISCH_DOCUMENT WHERE ONDERZOEK = 5 ORDER BY MD_ID DESC"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let queryResultCol1 = sqlite3_column_text(statement, 0)
            let docuDatum = String(cString: queryResultCol1!)
            dataMedicatieDocumentenArrayTemp.append(docuDatum)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return dataMedicatieDocumentenArrayTemp
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
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return mapID
        }
        
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
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        
        return mapID;
    }
    
    func getDocumentID(docunaam: String, specialisme: String, mapnaam: String) -> Int {
        var docuID = 1000
        
        let mapID = getMapID(mapnaam: mapnaam, specialisme: specialisme)
        
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return docuID
        }
        var statement: OpaquePointer?
        let sqlString = "SELECT MD_ID FROM MEDISCH_DOCUMENT WHERE TITEL = '\(docunaam)' AND SPECIALISME = '\(specialisme)' AND MAP = \(mapID)"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            docuID = Int(sqlite3_column_int(statement, 0))
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return docuID;
    }
    
    func getDocumentgegevens(hetDocumentID: Int) -> [String] {
        var documentGegevens: [String] = []
        if (sqlite3_open(databasePath, &db) != SQLITE_OK) {
            print("Error opening the database")
            return documentGegevens
        }
        var statement: OpaquePointer?
        let sqlString = "SELECT * FROM MEDISCH_DOCUMENT WHERE MD_ID = \(hetDocumentID)"
        
        if sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let documentID = String(cString:sqlite3_column_text(statement, 0))
            let titel = String(cString:sqlite3_column_text(statement, 1))
            let beschrijving = String(cString:sqlite3_column_text(statement, 2))
            let onderzoek = Int(sqlite3_column_int(statement, 3))
            let specialisme = String(cString:sqlite3_column_text(statement, 4))
            let artsnaam = String(cString:sqlite3_column_text(statement, 5))
            let mapID = Int(sqlite3_column_int(statement, 6))
            let fotouri = String(cString:sqlite3_column_text(statement, 7))
            let datum = String(cString:sqlite3_column_text(statement, 8))
            let filepath = String(cString:sqlite3_column_text(statement, 9))
            
            documentGegevens.append(documentID)
            documentGegevens.append(titel)
            documentGegevens.append(beschrijving)
            documentGegevens.append("\(onderzoek)")
            documentGegevens.append(specialisme)
            documentGegevens.append(artsnaam)
            documentGegevens.append("\(mapID)")
            documentGegevens.append(fotouri)
            documentGegevens.append(datum)
            documentGegevens.append(filepath)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing the database")
        }
        return documentGegevens;
    }
}
