//
//  ContentView.swift
//  schnitzeljagd_v2
//
//  Created by admin on 24.05.20.
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
//                HStack {
//                    ARUIView()
//                    if data.enableAR {ARDisplayView()}
//                    else {Spacer()}
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
        HStack {
            ARUIView()
            if data.enableAR {ARDisplayView()}
            else {Spacer()}
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
