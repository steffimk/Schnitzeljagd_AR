//
//  StateEnums.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 12.07.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

enum ScreenState {
    
    case MENU_MAP
    case SEARCH_SCHNITZEL_MAP
    case SEARCH_SCHNITZEL_AR
    case PLACE_SCHNITZEL_AR
    case SCOREBOARD
    
}

enum HelperState {
    
    case HELPER_INIT
    case HELPER_REQUESTED
    case HELPER_LOADING
    case HELPER_DONE
    
}
