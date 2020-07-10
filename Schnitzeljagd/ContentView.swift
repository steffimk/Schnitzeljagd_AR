//
//  ContentView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI
import RealityKit
import MapKit


struct ContentView : View {

    @EnvironmentObject var data: DataModel
    @EnvironmentObject var session: SessionStore
    @State private var showUserMenu = false
    @State private var isVeggie = false
          
    func getUser () {
          session.listen()
    }
               
    var body: some View {
          Group {
              if (session.session != nil){
        VStack {
          HStack {
                    Button(action: {
                              self.data.screenState = .MENU_MAP
                    }){
                  Image(systemName: "house").foregroundColor(.white).font(Font.system(.title))
              }
              Spacer()
                    if(self.data.screenState == .SCOREBOARD){
                              Text(TextEnum.scoreboard.rawValue)
                              .font(.title)
                              .fontWeight(.bold)
                              .foregroundColor(.white)
                    } else {
                            Text(TextEnum.appTitle.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
              Spacer()
                    Button(action: {self.showUserMenu.toggle()}){
                  Image(systemName: "person.crop.circle").foregroundColor(.white).font(Font.system(.largeTitle))
              }
              .popover(
                  isPresented: self.$showUserMenu,
                  arrowEdge: .top
              ) {
                    VStack{
                    Text("\(self.session.session?.email ?? "Schnitzel")" )
                              
//                    Divider()
//
//                    NavigationLink(destination: ContentView()) {
//                        Text("Found Schnitzel")
//                            .foregroundColor(Color.gray)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .padding(8)
//                    .frame(minWidth: 0, maxWidth: 200)
//
                    Divider()
                              
                              Toggle(isOn: self.$data.isVeggie) {
                                  //UIImage(named: "corn")
                                  Text("Vegetarier")
                              }.padding()
//
//                    NavigationLink(destination: ContentView()) {
//                        Text("User Settings")
//                            .foregroundColor(Color.gray)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .padding(8)
//                    .frame(minWidth: 0, maxWidth: 200)
                    
                    Divider()
                    
                    Button(action: {self.showUserMenu.toggle();
                              self.session.signOut() }){
                      Text("Logout")
                    }
                    }.frame(width: 200, height: 100, alignment: .top)
                    }.frame(alignment: .top)
          }.padding().padding(.top, -5)
            
            #if !targetEnvironment(simulator)
            if data.screenState == .PLACE_SCHNITZEL_AR {
                    ARDisplayView().padding(.top, -20).padding(.bottom, -200)
                    data.uiViews!.getPlaceSchnitzelUIView()
            } else if data.screenState == .SEARCH_SCHNITZEL_MAP {
                    SearchMapView().frame(maxHeight: .infinity).padding(.top, -20).padding(.bottom, -10)
                    data.uiViews!.getSearchMapUIView()
            } else if data.screenState == .MENU_MAP {
                    MapView().frame(maxHeight: .infinity).padding(.top, -20)
                    data.uiViews!.getMapUIView()
            } else if data.screenState == .SCOREBOARD {
                    ScoreboardView()
            } else {
                    ARDisplayView().padding(.top, -20).padding(.bottom, -10) // TODO: custom ARView for SearchSchnitzelAR
                    data.uiViews!.getSearchARUIView()
          }
            #endif
        }.background(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00))
              } else {
                    SignInView()
              }
          }.onAppear(perform: getUser)

    }
          
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionStore(session: User.default))
    }
}
#endif
