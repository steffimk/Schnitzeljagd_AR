//
//  NumberEnum.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 12.07.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

enum NumberEnum: Double {
    
    case regionRadius = 80.0
    case regionRadiusSmall = 60.0
    /** Radius around actual position of Schnitzel in which Schnitzel counts as found*/
    case foundRadius = 15.0
    /** Buffer of exiting a region to prevent flimmering in meters */
    case regionBuffer = 6.0
    case offsetBuffer = 4.0
    
}
