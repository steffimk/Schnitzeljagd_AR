//
//  ContentView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI
import RealityKit

//struct ContentView : View {
//
//    @EnvironmentObject var data: DataModel
//    @EnvironmentObject var session: SessionStore
//
//    func getUser () {
//        session.listen()
//    }
    
//    var body: some View {
//        Group {
//            if (session.session != nil){
//                VStack {
//                  if data.enableAR {ARDisplayView()}
//                  else {MapView()}
//                  ARUIView()
//                }
//            } else {
//                SignInView()
//            }
//        }.onAppear(perform: getUser)
//
//    }
//}

struct ContentView : View {
    @EnvironmentObject var data: DataModel
    var body: some View {
        VStack {
            if data.enableAR {ARDisplayView()}
            else {MapView()}
            ARUIView()
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(SessionStore())
    }
}
#endif
