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
            ZStack {
                Rectangle()
                    .fill(Color(red: 0, green: 119/255, blue: 27/255))
                    .frame(height: 150)
                    Text(TextEnum.appTitle.rawValue)
                    .position(x:130, y:100)
                    .foregroundColor(Color(red:1, green: 252/255, blue: 230/255))
                    .font(.system(size: 30, weight: .bold))
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                     RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red:1, green: 252/255, blue: 230/255))
                    }
                    
                    .frame(width: 50, height: 50)
                    .position(x:360, y:100)
                
            }
            .frame(width: 414, height: 100)
            .position(x:207, y: 0)
            
            #if !targetEnvironment(simulator)
            if data.enableAR {ARDisplayView()}
            else {MapView()}
            ARUIView()
            #endif
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
