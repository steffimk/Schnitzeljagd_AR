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

class SchnitzelJagd {
    
    var annotationWithRegion: AnnotationWithRegion
    var timePassed: Int
    
    init(annotation: AnnotationWithRegion) {
        self.annotationWithRegion = annotation
        self.timePassed = 0
    }
    
}

class AnnotationWithRegion : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    let region: CLCircularRegion
    let circle: MKCircle
    
    init(center: CLLocationCoordinate2D, radius: CLLocationDistance, regionIdentifier: String, title: String = TextEnum.annotationTitle.rawValue, subtitle: String = TextEnum.annotationSubtitle.rawValue) {
        self.coordinate = center
        self.title = title
        self.subtitle = subtitle
        
        self.region = CLCircularRegion(center: center, radius: radius, identifier: regionIdentifier)
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
        self.circle = MKCircle(center: center, radius: radius)

        super.init()
    }
}

class LoadedData : ObservableObject {
    
    @Published var loadedSchnitzelAnnotations: Set<AnnotationWithRegion>
    
    init(){
        loadedSchnitzelAnnotations = Set<AnnotationWithRegion>()
    }
    
    func observeAndLoadSchnitzelAnnotations() {
        let userID: String = (Auth.auth().currentUser?.uid)!
        DataModel.shared.ref.child("Location").child(userID).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let lat = value?["latitude"] as? CLLocationDegrees ?? 0
            let lon = value?["longitude"] as? CLLocationDegrees ?? 0
            print("Loaded Schnitzel Coordinates: \(lat) + \(lon)")
            let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let schnitzelAnnotation = AnnotationWithRegion(center: coordinateCenterSchnitzel, radius: NumberEnum.regionRadius.rawValue, regionIdentifier: "SchnitzelRegion Dummy")
            self.loadedSchnitzelAnnotations.insert(schnitzelAnnotation)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
