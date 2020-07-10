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
    case scoreboard = "Highscores"
    case AR = "AR"
    case placeARSchnitzel = "Neues Schnitzel"
    case placeARMais = "Neuer Maiskolben"
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
    
    // Load Helper Schnitzel Alert
    case helperAlertTitle = "Schnitzel manuell laden"
    case helperAlertMessage = "Das Schnitzel erscheint nicht, obwohl du die richtige Stelle gefunden hast? Dann lade es jetzt manuell."
    case helperNotAvailable = "Du bist noch zu weit vom Schnitzel entfernt, um es manuell laden zu können"
    case helperSuggested = "Du kannst das Schnitzel manuell laden, in dem du auf das Schnitzel-Symbol drückst."
    case helperLoading = "Das Schnitzel wird platziert, sobald eine horizontale Ebene gefunden wurde."
    
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
    case cornEntity = "corn"
}

enum NumberEnum: Double {
    
    case regionRadius = 80.0
    case regionRadiusSmall = 40.0
    /** Radius around actual position of Schnitzel in which Schnitzel counts as found*/
    case foundRadius = 48.0 // TODO
    /** Buffer of exiting a region to prevent flimmering in meters */
    case regionBuffer = 6.0
    case offsetBuffer = 4.0
    
}
