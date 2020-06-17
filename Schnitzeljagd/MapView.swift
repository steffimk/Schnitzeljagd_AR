//
//  MapView.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 14.05.20.
//  Copyright © 2020 Gruppe 2 PiOSE. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
import Firebase

struct MapView: UIViewRepresentable {
    
    @ObservedObject var loadedData: LoadedData = DataModel.shared.loadedData!
    
    func makeUIView(context: Context) -> MKMapView {
        startLocationServices()
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = DataModel.shared.mapViewDelegate
        mapView.showsCompass = true
        loadSchnitzelCoordinates()
        
        // TODO: Following is just for testing
//        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1664, longitude: 11.5858) // Leo
////        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1508, longitude: 11.5803) // LMU
////        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.3868, longitude: 9.9500) // Söflingen
//        let schnitzelAnnotation = AnnotationWithRegion(center: coordinateCenterSchnitzel, radius: 80, regionIdentifier: "SchnitzelRegion Uni")
//        DataModel.shared.locationManager.startMonitoring(for: schnitzelAnnotation.region)
//        mapView.addAnnotation(schnitzelAnnotation)
//        mapView.addOverlay(schnitzelAnnotation.circle)
                
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("MapView is being updated")

        uiView.removeAnnotations(uiView.annotations)
        for annotation in loadedData.loadedSchnitzelAnnotations {
            uiView.addAnnotation(annotation)
            uiView.addOverlay(annotation.circle)
            DataModel.shared.locationManager.startMonitoring(for: annotation.region)
        }
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        DataModel.shared.locationManager.stopUpdatingLocation()
    }
    
    func startLocationServices() {
        DataModel.shared.locationManager.desiredAccuracy = kCLLocationAccuracyBest // Accuracy of location - keep as low as possible to minimize power consumption
        DataModel.shared.locationManager.pausesLocationUpdatesAutomatically = true
        DataModel.shared.locationManager.startUpdatingLocation()
    }
    
    func loadSchnitzelCoordinates() {
        let userID: String = (Auth.auth().currentUser?.uid)!
        DataModel.shared.ref.child("Location").child(userID).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let lat = value?["latitude"] as? CLLocationDegrees ?? 0
            let lon = value?["longitude"] as? CLLocationDegrees ?? 0
            print("Loaded Schnitzel Coordinates: \(lat) + \(lon)")
            let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let schnitzelAnnotation = AnnotationWithRegion(center: coordinateCenterSchnitzel, radius: 80, regionIdentifier: "SchnitzelRegion Dummy")
            DataModel.shared.loadedData!.loadedSchnitzelAnnotations.insert(schnitzelAnnotation)
        }) { (error) in
            print(error.localizedDescription)
        }
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

struct SearchMapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MKMapView {
        startLocationServices()
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = DataModel.shared.mapViewDelegate
        mapView.showsCompass = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let schnitzelAnnotation = DataModel.shared.schnitzelJagd!.annotationWithRegion
        uiView.addOverlay(schnitzelAnnotation.circle)
        print("SearchMapView updated")
        let shownRegion = MKCoordinateRegion(center: schnitzelAnnotation.coordinate, latitudinalMeters: CLLocationDistance(exactly: 200)!, longitudinalMeters: CLLocationDistance(exactly: 200)!)
        uiView.setRegion(uiView.regionThatFits(shownRegion), animated: true)
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        DataModel.shared.locationManager.stopUpdatingLocation()
    }
    
    func startLocationServices(){
        DataModel.shared.locationManager.desiredAccuracy = kCLLocationAccuracyBest // Accuracy of location - keep as low as possible to minimize power consumption
        DataModel.shared.locationManager.pausesLocationUpdatesAutomatically = true
        DataModel.shared.locationManager.startUpdatingLocation()
    }
    
}

class MapViewDelegate : NSObject, MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
          mapView.showsUserLocation = true
        if DataModel.shared.screenState == .MENU_MAP {
            mapView.userTrackingMode = .followWithHeading
        }
    }
        
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let circleRenderer = MKCircleRenderer(overlay: overlay)
        if DataModel.shared.screenState == .SEARCH_SCHNITZEL_MAP {
            circleRenderer.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circleRenderer.strokeColor = .red
            circleRenderer.lineWidth = 1
        } else {
            circleRenderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            circleRenderer.strokeColor = .black
            circleRenderer.lineWidth = 1
        }
        
        return circleRenderer
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if DataModel.shared.screenState == .MENU_MAP, let annotationWithRegion = view.annotation as? AnnotationWithRegion {
            if DataModel.shared.currentRegions.contains(annotationWithRegion.region) {
                DataModel.shared.schnitzelJagd = SchnitzelJagd(annotation: annotationWithRegion)
                DataModel.shared.showStartSearchAlert = true
              }
        }
        print("Annotation was selected")
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Annotation was deselected")
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
