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
//        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1664, longitude: 11.5858) // Leo
        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1508, longitude: 11.5803) // LMU
//        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.3868, longitude: 9.9500) // Söflingen
        let schnitzelAnnotation = AnnotationWithRegion(center: coordinateCenterSchnitzel, radius: 50, regionIdentifier: "SchnitzelRegion Dummy")
        DataModel.shared.locationManager.startMonitoring(for: schnitzelAnnotation.region)
        uiView.addAnnotation(schnitzelAnnotation)
        uiView.addOverlay(schnitzelAnnotation.circle)
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

class MapViewDelegate : NSObject, MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
          mapView.showsUserLocation = true
          mapView.userTrackingMode = .followWithHeading
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

          let circleRenderer = MKCircleRenderer(overlay: overlay)
          circleRenderer.fillColor = .black
          circleRenderer.alpha = 0.2

          return circleRenderer
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
          if let annotationWithRegion = view.annotation as? AnnotationWithRegion {
              if DataModel.shared.currentRegions.contains(annotationWithRegion.region) {
                  DataModel.shared.showStartChaseAlert = true
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
