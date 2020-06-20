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
    
    // Entered Region
    case alertTitle = "Schnitzeljagd starten"
    case alertMessage = "Möchtest du die Schnitzeljagd annehmen?"
    case alertAccept = "Ja"
    case alertDecline = "Nein"
    
}

enum NumberEnum: Double {
    
    case regionRadius = 80
    
    /** Buffer of exiting a region to prevent flimmering in meters */
    case regionBuffer = 5
    
}
