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
          
    func getUser () {
          session.listen()
    }
          
    var body: some View {
          Group {
              if (session.session != nil){
        VStack {
          HStack {
                    Button(action: { self.data.screenState = .MENU_MAP }){
                  Image(systemName: "house").foregroundColor(.white).font(Font.system(.title))
              }
              Spacer()
                  Text(TextEnum.appTitle.rawValue)
                  .font(.title)
                  .fontWeight(.bold)
                  .foregroundColor(.white)
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
                              
                    Divider()
                              
                    NavigationLink(destination: ContentView()) {
                        Text("Found Schnitzel")
                            .foregroundColor(Color.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(8)
                    .frame(minWidth: 0, maxWidth: 200)
                    
                    Divider()
                              
                    NavigationLink(destination: ContentView()) {
                        Text("User Settings")
                            .foregroundColor(Color.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(8)
                    .frame(minWidth: 0, maxWidth: 200)
                    
                    Divider()
                    
                    Button(action: {self.showUserMenu.toggle();
                              self.session.signOut() }){
                      Text("Logout")
                    }
                    }.frame(width: 200, height: 100, alignment: .top)
                    }.frame(alignment: .top)
          }.padding()
            
            #if !targetEnvironment(simulator)
            if data.screenState == .PLACE_SCHNITZEL_AR {
                ARDisplayView().padding(.top, -15).padding(.bottom, -90)
                PlaceSchnitzelUIView()
            } else if data.screenState == .SEARCH_SCHNITZEL_MAP {
                SearchMapView().frame(maxHeight: .infinity).padding(.top, -15)
                SearchMapUIView()
            } else if data.screenState == .MENU_MAP {
                MapView().frame(maxHeight: .infinity).padding(.top, -15)
                MapUIView()
            } else {
                ARDisplayView().padding(.top, -15).padding(.bottom, -90) // TODO: custom ARView for SearchSchnitzelAR
                SearchARUIView()
          }
            #endif
        }.background(getBackgroundColor())
          .alert(isPresented: $data.showStartSearchAlert) {
                  Alert(title: Text(TextEnum.alertTitle.rawValue), message: Text(TextEnum.alertMessage.rawValue),
                        primaryButton: .default(Text(TextEnum.alertAccept.rawValue), action: {
                            DataModel.shared.screenState = .SEARCH_SCHNITZEL_MAP
                            DataModel.shared.showStartSearchAlert = false
                        }),
                        secondaryButton: .cancel(Text(TextEnum.alertDecline.rawValue), action: {
                            DataModel.shared.showStartSearchAlert = false
                        }))
        }
              } else {
                    SignInView()
              }
          }.onAppear(perform: getUser)

    }
          
          func getBackgroundColor() -> Color {
                    switch data.screenState{
                    case .SEARCH_SCHNITZEL_MAP, .SEARCH_SCHNITZEL_AR: return Color.orange
                    default: return Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00) //darkgreen
                    }
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
