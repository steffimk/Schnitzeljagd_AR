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
    
    @ObservedObject var loadedData: LoadedData = DataModel.shared.loadedData
    
    func makeUIView(context: Context) -> MKMapView {
        startLocationServices()
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = DataModel.shared.mapViewDelegate
        mapView.showsCompass = true
        DataModel.shared.loadedData.observeAndLoadSchnitzelAnnotations()
        
        // TODO: Following is just for testing
//        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1664, longitude: 11.5858) // Leo
//        let coordinateCenterSchnitzel = CLLocationCoordinate2D(latitude: 48.1508, longitude: 11.5803) // LMU
        let coordinateSchnitzel = CLLocationCoordinate2D(latitude: 48.3868, longitude: 9.9500) // Söflingen
        let shifting = AnnotationWithRegion.calculateRandomCenter(latitude: coordinateSchnitzel.latitude, longitude: coordinateSchnitzel.longitude, maxOffsetInMeters: Int(NumberEnum.regionRadius.rawValue))
        let center = CLLocationCoordinate2D(latitude: shifting.latitude, longitude: shifting.longitude)
        let schnitzelLMUAnnotation = AnnotationWithRegion(actualLocation: coordinateSchnitzel, center: center, radius: NumberEnum.regionRadius.rawValue, regionIdentifier: "HC Region", isOwned: false)
        let schnitzelJagd = SchnitzelJagd(id: "SelbstEingefügt", ownerId: "NoOne", annotation: schnitzelLMUAnnotation)
        loadedData.loadedSchnitzel.insert(schnitzelJagd)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("MapView is being updated")

        uiView.removeAnnotations(uiView.annotations)
        for schnitzel in loadedData.loadedSchnitzel {
            let annotation = schnitzel.annotationWithRegion
            uiView.addAnnotation(annotation)
            uiView.addOverlay(annotation.circle)
        }
    }
    
    func startLocationServices() {
        DataModel.shared.locationManager.desiredAccuracy = kCLLocationAccuracyBest // Accuracy of location - keep as low as possible to minimize power consumption
        DataModel.shared.locationManager.pausesLocationUpdatesAutomatically = true
        DataModel.shared.locationManager.startUpdatingLocation()
    }
    
}

struct SearchMapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = DataModel.shared.mapViewDelegate
        mapView.showsCompass = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let schnitzelAnnotation = DataModel.shared.loadedData.currentSchnitzelJagd!.annotationWithRegion
        uiView.addOverlay(schnitzelAnnotation.circle)
        print("SearchMapView updated")
        let shownRegion = MKCoordinateRegion(center: schnitzelAnnotation.coordinate, latitudinalMeters: CLLocationDistance(exactly: 200)!, longitudinalMeters: CLLocationDistance(exactly: 200)!)
        uiView.setRegion(uiView.regionThatFits(shownRegion), animated: true)
        
//        let actualSchnitzel = MKPointAnnotation(__coordinate: schnitzelAnnotation.actualLocation)
//        uiView.addAnnotation(actualSchnitzel)
    }
    
}

class MapViewDelegate : NSObject, MKMapViewDelegate {
    
    let schnitzelViewIdentifier: String = "SchnitzelViewIdentifier"
    let schnitzelBWViewIdentifier: String = "SchnitzelBWViewIdentifier"
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
          mapView.showsUserLocation = true
        if DataModel.shared.screenState == .MENU_MAP {
            mapView.userTrackingMode = .followWithHeading
        }
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationWithRegion = annotation as? AnnotationWithRegion {
            var imageName: String
            var identifier: String
            if annotationWithRegion.isOwned {
                imageName = "fleisch_bw"
                identifier = schnitzelBWViewIdentifier
            } else {
                imageName = "fleisch"
                identifier = schnitzelViewIdentifier
            }
            var annotationView: MKAnnotationView?
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            }
            else {
                let newAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                newAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                annotationView = newAnnotationView
            }
            if let annotationView = annotationView {
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: imageName)
            }

            return annotationView
        }
        return nil
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
            if !annotationWithRegion.isOwned && DataModel.shared.currentRegions.contains(annotationWithRegion.region) {
                DataModel.shared.loadedData.setCurrentSchnitzelJagd(annotation: annotationWithRegion)
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
