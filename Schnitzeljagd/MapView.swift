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
        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1508, longitude: 11.5803)
        let mapAnnotationSchnitzel = MapAnnotation(coordinate: coordinateCenterSchnitzel, title: TextEnum.annotationTitle.rawValue, subtitle: TextEnum.annotationSubtitle.rawValue)
        let schnitzelRegion = CLCircularRegion(center: coordinateCenterSchnitzel, radius: 50, identifier: "Probe Schnitzel-Region")
        DataModel.shared.locationManager.startMonitoring(for: schnitzelRegion)
        uiView.addAnnotation(mapAnnotationSchnitzel)
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

class MapAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate:CLLocationCoordinate2D, title: String?, subtitle: String?){
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
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
