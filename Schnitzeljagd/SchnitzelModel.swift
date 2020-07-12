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
import ARKit

class SchnitzelJagd : Hashable {
    
    var schnitzelId: String
    var ownerId: String
    
    var annotationWithRegion: AnnotationWithRegion
    var timePassed: Int
    var couldUpdate: Bool
    var worldMap: ARWorldMap?

    var failedLoadingWorldMap: Bool
    var score: Int

    var isFound: Bool
    
    var snapshot: UIImage?
    
    init(id: String, ownerId: String, annotation: AnnotationWithRegion) {
        self.schnitzelId = id
        self.ownerId = ownerId
        self.annotationWithRegion = annotation
        self.timePassed = 0
        self.couldUpdate = false
        self.failedLoadingWorldMap = false
        self.isFound = false
        self.score = 0
    }
    
    func readyForSearch() -> Bool {
        return self.couldUpdate && !self.isFound && !self.annotationWithRegion.isOwned && DataModel.shared.currentRegions.contains(self.annotationWithRegion.region)
    }
    
    func loadInformation() {
        let userID = Auth.auth().currentUser?.uid
        
        // Load time
        DataModel.shared.ref.child("Jagd").child(userID!).child(schnitzelId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? Dictionary<String,Any>
            self.timePassed = value?["CurrentDuration"] as? Int ?? self.timePassed
            let finalTime = value?["FinalTime"] as? Int
            if finalTime != nil {
                self.isFound = true
                return
            }
            let availableHints = value?["Hints"] as? Int
            if (availableHints == nil){
                DataModel.shared.ref.child("Jagd").child(userID!).child(self.schnitzelId).child("Hints").setValue(4)
            }
            self.couldUpdate = true
            print("data loaded - time passed: \(self.timePassed), isFound: \(self.isFound)")
          }) { (error) in
            print(error.localizedDescription)
        }
        
        // Load score
        DataModel.shared.ref.child("Jagd").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? Dictionary<String,Any>
            let score = value?["Score"] as? Int
                if (score == nil){
                    DataModel.shared.ref.child("Jagd").child(userID!).child("Score").setValue(self.score)
                } else {
                    self.score = score!
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //Load world map
        loadWorldMap()

    }
    
    func loadWorldMap(){
        
        DataModel.shared.ref.child("Schnitzel").child(self.schnitzelId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let schnitzelData = value?["Worldmap"] as? String ?? ""
            let data = Data(base64Encoded: schnitzelData)!
            
            guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
            else{
                self.failedLoadingWorldMap = true
                print("No ARWorldMap in archive.")
                return
            }
    
            if let snapshot = worldMap.snapshotAnchor?.imageData,
                let snapshotThumbnail = UIImage(data: snapshot) {
                self.snapshot = snapshotThumbnail
                worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })
            } else {
                print("Snapshot was not loaded for schnitzel with id \(self.schnitzelId)")
            }
            
            self.worldMap = worldMap
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func determineDistanceToSchnitzel() -> Double {
        return DataModel.shared.locationManager.location!.distance(from: CLLocation(latitude: annotationWithRegion.actualLocation.latitude, longitude: annotationWithRegion.actualLocation.longitude))
    }
    
    func saveTime() {
        if !self.isFound {
            let userID = Auth.auth().currentUser?.uid
            DataModel.shared.ref.child("Jagd").child(userID!).child(schnitzelId).child("CurrentDuration").setValue(timePassed)
        }
    }
    
    func setHints(){
        if !self.isFound {
            let userID = Auth.auth().currentUser?.uid
            DataModel.shared.ref.child("Jagd").child(userID!).child(schnitzelId).child("Hints").setValue(4)
        }
    }
    
    func found() {
        if !self.isFound {
            self.isFound = true
            let userID = Auth.auth().currentUser?.uid
            DataModel.shared.ref.child("Jagd").child(userID!).child(schnitzelId).child("FinalTime").setValue(timePassed)
            let score = self.score + Int(powf(Float(M_E), Float(1/timePassed))) * 2000
            DataModel.shared.ref.child("Jagd").child(userID!).child("Score").setValue(score)
        }
    }
    
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
    let circleSmall: MKCircle
    
    init(actualLocation: CLLocationCoordinate2D, center: CLLocationCoordinate2D, radius: CLLocationDistance, centerSmall: CLLocationCoordinate2D, radiusSmall: CLLocationDistance, regionIdentifier: String, title: String = TextEnum.annotationTitle.rawValue, subtitle: String = TextEnum.annotationSubtitle.rawValue, isOwned: Bool) {
        self.actualLocation = actualLocation
        self.coordinate = center
        self.title = title
        self.subtitle = subtitle
        self.isOwned = isOwned
        self.region = CLCircularRegion(center: center, radius: radius, identifier: regionIdentifier)
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
        self.circle = MKCircle(center: center, radius: radius)
        self.circleSmall = MKCircle(center: centerSmall, radius: radiusSmall)

        super.init()
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
                    if !self.getSchnitzelWithId(id: key).hasSchnitzel && element.keys.contains("User") && element.keys.contains("Titel") && element.keys.contains("Description") && element.keys.contains("Location") && element.keys.contains("RegionCenter"){
                        let schnitzelId = key
                        let userId = element["User"] as? String ?? ""
                        let title = element["Titel"] as? String ?? "Title not loaded"
                        let description = element["Description"] as? String ?? "Description not loaded"
                        let location = element["Location"] as? Dictionary<String, CLLocationDegrees>
                        let lat = location?["latitude"] ?? 0.0
                        let lon = location?["longitude"] ?? 0.0
                        let regionCenter = element["RegionCenter"] as? Dictionary<String, CLLocationDegrees>
                        let regionCenterSmall = element["RegionCenterSmall"] as? Dictionary<String, CLLocationDegrees>
                        let centerLat = regionCenter?["latitude"] ?? 0.0
                        let centerLon = regionCenter?["longitude"] ?? 0.0
                        let centerLatSmall = regionCenterSmall?["latitude"] ?? 0.0
                        let centerLonSmall = regionCenterSmall?["longitude"] ?? 0.0
                        
                        // TODO: Improve management: Only add Schnitzel when not more than x kilometers
                        print("Loaded Schnitzel \(title) \(description) with Id \(schnitzelId) and coordinates \(lat) + \(lon) from user \(userId)")

                        let coordinateAnnotation = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
                        let coordinateAnnotationSmall = CLLocationCoordinate2D(latitude: centerLatSmall, longitude: centerLonSmall)
                        let coordinateSchnitzel = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        let schnitzelAnnotation = AnnotationWithRegion(actualLocation: coordinateSchnitzel, center: coordinateAnnotation, radius: NumberEnum.regionRadius.rawValue, centerSmall: coordinateAnnotationSmall, radiusSmall: NumberEnum.regionRadiusSmall.rawValue, regionIdentifier: schnitzelId, title: title, subtitle: description, isOwned: userId == currentUserId)

                        let schnitzel = SchnitzelJagd(id: schnitzelId, ownerId: userId, annotation: schnitzelAnnotation)

                        self.loadedSchnitzel.insert(schnitzel)
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getSchnitzelWithId(id: String) -> (hasSchnitzel: Bool, schnitzel: SchnitzelJagd?){
        for schnitzel in self.loadedSchnitzel {
            if schnitzel.schnitzelId == id {
                return (hasSchnitzel: true, schnitzel: schnitzel)
            }
        }
        return (hasSchnitzel: false, schnitzel: nil)
    }
    
    func setCurrentSchnitzelJagd(annotation: AnnotationWithRegion) {
        for schnitzel in loadedSchnitzel {
            if schnitzel.annotationWithRegion == annotation {
                self.currentSchnitzelJagd = schnitzel
                schnitzel.couldUpdate = false
                schnitzel.loadInformation()
                DataModel.shared.showStartSearchAlert = true
            }
        }
    }
    
}
