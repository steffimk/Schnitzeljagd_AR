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
    case searchMap = "Kartenansicht"
    case menuMap =  "Jagd beenden"
    case save = "save"
    case load = "load"
    
    // MapView Messages
    case annotationTitle = "Schnitzel"
    case annotationSubtitle = "Im Umkreis von 80m befindet sich ein Schnitzel"
    
    // Start Schnitzeljagd Alert
    case alertTitle = "Schnitzeljagd starten"
    case alertMessage = "Möchtest du die Schnitzeljagd annehmen?"
    case alertAccept = "Ja"
    case alertDecline = "Nein"
    
    // Save Schnitzel Alert
    case saveAlertTitle = "Schnitzel speichern"
    case saveAlertAccept = "Speichern"
    case saveAlertDecline = "Bearbeiten"
    case schnitzelTitlePlaceholder = "Dein Titel"
    case schnitzelDescriptionPlaceholder = "Deine Beschreibung"
}

enum NumberEnum: Double {
    
    case regionRadius = 80.0
    /** Buffer of exiting a region to prevent flimmering in meters */
    case regionBuffer = 5.0
    case offsetBuffer = 4.0
    /** Color is updated after this amount of seconds*/
    case delay = 3.0
    
}
