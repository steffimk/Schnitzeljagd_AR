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
     @State var showUserMenu = false
     @State private var isVeggie = false
          
     func getUser () {
          session.listen()
     }
          
     var body: some View {
          Group {
               if (self.session.session != nil){
               VStack {
                    HStack {
                         Button(action: { self.data.screenState = .MENU_MAP}){
                              Image(systemName: "house").foregroundColor(.white).font(Font.system(.title))
                         }
                         Spacer()
                         VStack {
                              if (self.data.screenState == .MENU_MAP || self.data.screenState == .PLACE_SCHNITZEL_AR){
                                   Text(self.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                              } else {
                                   Text(self.title)
                                        .font(.system(size: 22))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                   Text(self.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                              }
                          }
                          Spacer()
                          Button(action: {self.showUserMenu.toggle()}){
                              Image(systemName: "person.crop.circle").foregroundColor(.white).font(Font.system(.largeTitle))
                          }.popover(isPresented: self.$showUserMenu,arrowEdge: .top) {
                               PopOver(contentView: self)
                         }.frame(alignment: .top)
                    }.padding().padding(.top, -5)
                                        
                    #if !targetEnvironment(simulator)
                    if self.data.screenState == .PLACE_SCHNITZEL_AR {
                         ARDisplayView().padding(.top, -20).padding(.bottom, -200)
                         self.data.uiViews!.getPlaceSchnitzelUIView()
                    } else if self.data.screenState == .SEARCH_SCHNITZEL_MAP {
                         SearchMapView().frame(maxHeight: .infinity).padding(.top, -20).padding(.bottom, -10)
                         self.data.uiViews!.getSearchMapUIView()
                    } else if self.data.screenState == .MENU_MAP {
                         MapView().frame(maxHeight: .infinity).padding(.top, -20)
                         self.data.uiViews!.getMapUIView()
                    } else if data.screenState == .SCOREBOARD {
                         ScoreboardView()
                    } else {
                         ARDisplayView().padding(.top, -20).padding(.bottom, -10)
                         self.data.uiViews!.getSearchARUIView()
                    }
                    #endif
                    }.background(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00))
               } else {
                    SignInView()
               }
          }.onAppear(perform: self.getUser).onTapGesture {
               UIApplication.shared.endEditing()
          }
     }
      
          var title: String {
                    switch(DataModel.shared.screenState){
                    case .SEARCH_SCHNITZEL_MAP:
                         return data.loadedData.currentSchnitzelJagd?.annotationWithRegion.title ?? TextEnum.appTitle.rawValue
                    case .SEARCH_SCHNITZEL_AR:
                         return data.loadedData.currentSchnitzelJagd?.annotationWithRegion.title ?? TextEnum.appTitle.rawValue
                    case .SCOREBOARD:
                         return TextEnum.scoreboard.rawValue
                    default: return TextEnum.appTitle.rawValue
                    }
          }
          
          var subtitle: String {
                    switch(DataModel.shared.screenState){
                    case .SEARCH_SCHNITZEL_MAP:
                         return data.loadedData.currentSchnitzelJagd?.annotationWithRegion.subtitle ?? TextEnum.searchMapSubtitle.rawValue
                    default:
                         return data.loadedData.currentSchnitzelJagd?.annotationWithRegion.subtitle ?? TextEnum.searchARSubtitle.rawValue
                    }
          }
}

struct PopOver : View {
          
     let contentView: ContentView
          
     var body: some View {
          VStack{
               Text("\(self.contentView.session.session?.email ?? "Schnitzel")" )
//               Divider()
//               NavigationLink(destination: ContentView()) {
//                    Text("Found Schnitzel")
//                         .foregroundColor(Color.gray)
//               }.buttonStyle(PlainButtonStyle())
//                    .padding(8)
//                    .frame(minWidth: 0, maxWidth: 200)
               Divider()
                    Toggle(isOn: self.contentView.$data.isVeggie) {
                        Image("corn")
                        Text("Vegetarier")
                    }.padding()
//               NavigationLink(destination: ContentView()) {
//                    Text("User Settings")
//                         .foregroundColor(Color.gray)
//               }.buttonStyle(PlainButtonStyle())
//                    .padding(8)
//                    .frame(minWidth: 0, maxWidth: 200)
               Divider()
                    Button(action: { self.contentView.showUserMenu.toggle(); self.contentView.session.signOut() }){
                    Text("Logout")
               }
          }.frame(width: 200, height: 100, alignment: .top)
     }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
