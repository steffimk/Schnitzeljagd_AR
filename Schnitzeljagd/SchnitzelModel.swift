//
//  SchnitzelModel.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 20.06.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import CoreLocation
import MapKit
import Firebase

class SchnitzelJagd : Hashable {
    
    var schnitzelId: String
    var ownerId: String
    
    var annotationWithRegion: AnnotationWithRegion
    var timePassed: Int
    
    init(id: String, ownerId: String, annotation: AnnotationWithRegion) {
        self.schnitzelId = id
        self.ownerId = ownerId
        self.annotationWithRegion = annotation
        self.timePassed = 0
    }
    
    // TODO: Get time and status before starting new Jagd
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(schnitzelId)
    }
    
    static func == (lhs: SchnitzelJagd, rhs: SchnitzelJagd) -> Bool {
        return lhs.schnitzelId == rhs.schnitzelId
    }
    
}

class AnnotationWithRegion : NSObject, MKAnnotation {
    var actualLocation: CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var isOwned: Bool
    
    let region: CLCircularRegion
    let circle: MKCircle
    
    init(actualLocation: CLLocationCoordinate2D, center: CLLocationCoordinate2D, radius: CLLocationDistance, regionIdentifier: String, title: String = TextEnum.annotationTitle.rawValue, subtitle: String = TextEnum.annotationSubtitle.rawValue, isOwned: Bool) {
        self.actualLocation = actualLocation
        self.coordinate = center
        self.title = title
        self.subtitle = subtitle
        self.isOwned = isOwned
        
        self.region = CLCircularRegion(center: center, radius: radius, identifier: regionIdentifier)
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
        self.circle = MKCircle(center: center, radius: radius)

        super.init()
    }
    
      static func calculateRandomCenter(latitude: CLLocationDegrees, longitude: CLLocationDegrees, maxOffsetInMeters: Int) -> (latitude: Double, longitude: Double){

          let earthRadius: Double = 6378137
          
          let xOffset = Int.random(in: 0...maxOffsetInMeters*2) - maxOffsetInMeters
          let yOffset = Int.random(in: 0...maxOffsetInMeters*2) - maxOffsetInMeters
    
          let latitudeOffset: Double = Double(xOffset)/earthRadius
          let longitudeOffset: Double = Double(yOffset)/(earthRadius * cos(Double.pi * latitude/180.0))

        let latitudeResult: Double = latitude + latitudeOffset * 180.0/Double.pi
        let longitudeResult: Double = longitude + longitudeOffset * 180.0/Double.pi
          
          return (latitude: latitudeResult, longitude: longitudeResult)
      }
}

class LoadedData : ObservableObject {
    
    /** All Schnitzel in the database*/
    @Published var loadedSchnitzel: Set<SchnitzelJagd>
    /** The schnitzel that is currently searched by the user*/
    var currentSchnitzelJagd: SchnitzelJagd?
    
    init(){
        loadedSchnitzel = Set<SchnitzelJagd>()
    }
    
    func observeAndLoadSchnitzelAnnotations() {
        let currentUserId: String = (Auth.auth().currentUser?.uid)!
        
        DataModel.shared.ref.child("Schnitzel").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? Dictionary<String, Dictionary<String, Any>>
            if value != nil {
                for (key, element) in value! {
                    let schnitzelId = key
                    let userId = element["User"] as? String ?? ""
                    let title = element["Titel"] as? String ?? "Title not loaded"
                    let description = element["Description"] as? String ?? "Description not loaded"
                    let location = element["Location"] as! Dictionary<String, CLLocationDegrees>
                    let lat = location["latitude"] ?? 0.0
                    let lon = location["longitude"] ?? 0.0
                    let regionCenter = element["RegionCenter"] as! Dictionary<String, CLLocationDegrees>
                    let centerLat = regionCenter["latitude"] ?? 0.0
                    let centerLon = regionCenter["longitude"] ?? 0.0
                    // TODO: Maybe only add Schnitzel when not more than x kilometers away
                    print("Loaded Schnitzel \(title) \(description) with Id \(schnitzelId) and coordinates \(lat) + \(lon) from user \(userId)")
                    let coordinateAnnotation = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
                    let coordinateSchnitzel = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    let schnitzelAnnotation = AnnotationWithRegion(actualLocation: coordinateSchnitzel, center: coordinateAnnotation, radius: NumberEnum.regionRadius.rawValue, regionIdentifier: schnitzelId, title: title, subtitle: description, isOwned: userId == currentUserId)

                    let schnitzel = SchnitzelJagd(id: schnitzelId, ownerId: userId, annotation: schnitzelAnnotation)
                    
                    self.loadedSchnitzel.insert(schnitzel)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setCurrentSchnitzelJagd(annotation: AnnotationWithRegion) {
        for schnitzel in loadedSchnitzel {
            if schnitzel.annotationWithRegion == annotation {
                currentSchnitzelJagd = schnitzel
                return
            }
        }
    }
    
}
