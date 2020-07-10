//
//  TextEnum.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 03.06.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import Foundation

/**
 An enum containing all strings/messages that are displayed in the app
 */
enum TextEnum: String {
    
    // Basic Messages
    case appTitle = "Schnitzeljagd"
    case AR = "AR"
    case placeAR = "Neues Schnitzel"
    case searchAR = "AR Modus"
    case searchMap = "Karte"
    case menuMap =  "Jagd beenden"
    
    //Subtitles
    case searchMapSubtitle = "Achte auf das Farbfeedback"
    case searchARSubtitle = "Lade das Schnitzel in deine Welt"
    
    case save = "Speichern"
    case load = "Laden"
    case dismiss = "Abbrechen"
    case okay = "Okay"
    case close = "Schließen"
    
    // MapView Messages
    case annotationTitle = "Schnitzel"
    case annotationSubtitle = "Im Umkreis von 80m befindet sich ein Schnitzel"
    
    // Start Schnitzeljagd Alert
    case alertTitle = "Schnitzeljagd starten"
    case alertMessage = "Möchtest du die Schnitzeljagd annehmen?"
    case alertLoadMessage = "Schnitzel wird gebraten! Wir bitten um etwas Geduld..."
    case alertFoundMessage = "Du hast dieses Schnitzel bereits gefunden!"
    case alertAccept = "Ja"
    case alertDecline = "Nein"
    
    // Save Schnitzel Alert
    case saveAlertTitle = "Schnitzel speichern"
    case saveAlertDecline = "Bearbeiten"
    case schnitzelTitlePlaceholder = "Dein Titel"
    case schnitzelDescriptionPlaceholder = "Deine Beschreibung"
    case isSavingTitle = "Speichervorgang"
    case isSavingMessage = "Dein Schnitzel wird paniert. Bitte habe einen Moment Geduld."
    
    // Found Schnitzel Alert
    case foundAlertTitle = "Schnitzeljagd gewonnen"
    case foundAlertAccept = "Zum Menü"
    case foundAlertDecline = "Hier bleiben"
    
    // Missing Schnitzel Alert
    case missingAlertTitle = "Fehlendes Schnitzel"
    case missingAlertMessage = "Bitte platziere erst ein Schnitzel, indem du auf den Bildschirm tippst."
    
    // Missing WorldMapAlert
    case noWorldMapAlertTitel = "Umgebung scannen"
    case noWorldMapAlertMessage = "Bewege dein Handy langsam hin un her"
    
    // Names of anchors and entities in AR
    case schnitzelAnchorEntity = "SchnitzelAnchor"
    case schnitzelARAnchor = "SchnitzelARAnchor"
    case schnitzelEntity = "schnitzel"
}

enum NumberEnum: Double {
    
    case regionRadius = 80.0
    /** Radius around actual position of Schnitzel in which Schnitzel counts as found*/
    case foundRadius = 3.0
    /** Buffer of exiting a region to prevent flimmering in meters */
    case regionBuffer = 6.0
    case offsetBuffer = 4.0
    
}
