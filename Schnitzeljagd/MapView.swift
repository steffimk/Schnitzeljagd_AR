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
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
//        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        let coordinate = uiView.userLocation.coordinate
//        let region = MKCoordinateRegion(center: coordinate, span: span)
//        uiView.addAnnotation(MapAnnotation(coordinate: coordinateLMU, title: TextEnum.annotationTitle.rawValue, subtitle: TextEnum.annotationSubtitle.rawValue)) TODO: add annotations of schnitzel in the environment
//        uiView.setRegion(region, animated: true)
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        DataModel.shared.locationManager.stopUpdatingLocation()
    }
    
    func startLocationServices(){
        DataModel.shared.locationManager.desiredAccuracy = kCLLocationAccuracyBest
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
