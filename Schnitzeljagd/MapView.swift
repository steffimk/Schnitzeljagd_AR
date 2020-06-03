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
        return MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        var span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48, longitude: 12), span: span)
        if let coordinate = DataModel.shared.location?.coordinate{
            span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.addAnnotation(mapAnnotation(coordinate: coordinate, title: TextEnum.annotationLocTitle.rawValue, subtitle: TextEnum.annotationLocSubtitle.rawValue))
        }
        uiView.setRegion(region, animated: true)
    }
    
}

class mapAnnotation : NSObject, MKAnnotation {
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
