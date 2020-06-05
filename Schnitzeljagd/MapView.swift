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

struct MapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MKMapView {
        startLocationServices()
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = DataModel.shared.mapViewDelegate
        mapView.showsCompass = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
//        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1508, longitude: 11.5803)
        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.3868, longitude: 9.9500)
        let schnitzelRegion = SchnitzelRegion(center: coordinateCenterSchnitzel, radius: 70, regionIdentifier: "SchnitzelRegion Dummy")
        DataModel.shared.locationManager.startMonitoring(for: schnitzelRegion.region)
        uiView.addAnnotation(schnitzelRegion.annotation)
        uiView.addOverlay(schnitzelRegion.circle)
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

class SchnitzelRegion {
    let region: CLCircularRegion
    let annotation: MapAnnotation
    let circle: MKCircle
    
    init(center: CLLocationCoordinate2D, radius: CLLocationDistance, regionIdentifier: String){
        self.region = CLCircularRegion(center: center, radius: radius, identifier: regionIdentifier)
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
        self.annotation = MapAnnotation(coordinate: center, title: TextEnum.annotationTitle.rawValue, subtitle: TextEnum.annotationSubtitle.rawValue)
        self.circle = MKCircle(center: center, radius: radius)
    }
}

class MapAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
}

class MapViewDelegate : NSObject, MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
    }
    
    func mapView(_ mapView: MKMapView,
                  rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = .black
        circleRenderer.alpha = 0.2

        return circleRenderer
     }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
