//
//  ARUIView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI

import RealityKit
import MapKit

#if !targetEnvironment(simulator)

class UIViews {
    
    private let contentView: ContentView
    private var placeSchnitzelUIView: PlaceSchnitzelUIView?
    private var mapUIView: MapUIView?
    private var searchMapUIView: SearchMapUIView?
    private var searchARUIView: SearchARUIView?
    private var scoreboardView: ScoreboardView?
    
    init(contentView: ContentView){
        self.contentView = contentView
    }
    
    func getPlaceSchnitzelUIView() -> PlaceSchnitzelUIView {
        if placeSchnitzelUIView == nil {
            placeSchnitzelUIView = PlaceSchnitzelUIView()
        }
        return placeSchnitzelUIView!
    }
    
    func getMapUIView() -> MapUIView {
        if mapUIView == nil {
            mapUIView = MapUIView()
        }
        return mapUIView!
    }
    
    func getSearchMapUIView() -> SearchMapUIView {
        if searchMapUIView == nil {
            searchMapUIView = SearchMapUIView()
        }
        return searchMapUIView!
    }
    
    func getSearchARUIView() -> SearchARUIView {
        if searchARUIView == nil {
            searchARUIView = SearchARUIView()
        }
        return searchARUIView!
    }
    
    func getScoreboardView() -> ScoreboardView {
        if scoreboardView == nil {
            scoreboardView = ScoreboardView()
        }
        return scoreboardView!
    }
    
    func refreshAll() {
        self.placeSchnitzelUIView = PlaceSchnitzelUIView()
        self.mapUIView = MapUIView()
        if self.searchMapUIView != nil {
            self.searchMapUIView = SearchMapUIView()
        }
        if self.searchARUIView != nil {
            self.searchARUIView = SearchARUIView()
        }
        if self.scoreboardView != nil {
            self.scoreboardView = ScoreboardView()
        }
    }
}

struct PlaceSchnitzelUIView: View {
    @EnvironmentObject var data: DataModel
    @State var value: CGFloat = 0
    @State var title: String = ""
    @State var description: String = ""
    @State var showSaveAlert: Bool = false
    
    var body: some View {
        HStack {
            VStack {
                TextField("", text: $title).modifier(TextFieldStyle(font: .title, showPlaceHolder: title.isEmpty, placeholder: TextEnum.schnitzelTitlePlaceholder.rawValue))
                TextField("", text: $description).modifier(TextFieldStyle(font: .callout, showPlaceHolder: description.isEmpty, placeholder: TextEnum.schnitzelDescriptionPlaceholder.rawValue))
                Button(action: {
                    self.data.arView.checkWorldMap()
                    self.showSaveAlert = true
                    print("ShowSaveAlert is: \(self.showSaveAlert)")
                }) {
                    Text(TextEnum.save.rawValue)
                        .fontWeight(.bold)
                        .modifier(TextModifier(color: .yellow))
                }.alert(isPresented: self.$showSaveAlert) {
                    if (!self.data.hasPlacedSchnitzel) {
                        return Alert(title: Text(TextEnum.missingAlertTitle.rawValue), message: Text(TextEnum.missingAlertMessage.rawValue),
                                     dismissButton: .default(Text(TextEnum.close.rawValue), action: {
                          self.showSaveAlert = false
                        }))
                    } else if (self.data.showMissingWorldmapAlert) {
                        return Alert(title: Text(TextEnum.noWorldMapAlertTitel.rawValue), message: Text(TextEnum.noWorldMapAlertMessage.rawValue),
                                     dismissButton: .default(Text(TextEnum.close.rawValue), action: {
                          self.showSaveAlert = false
                          self.data.showMissingWorldmapAlert = false
                        }))
                    } else if (self.data.isTakingSnapshot) { // Time to take screenshot
                        return Alert(title: Text(TextEnum.isSavingTitle.rawValue), message: Text(TextEnum.isSavingMessage.rawValue),
                                dismissButton: .default(Text(TextEnum.dismiss.rawValue), action: {
                                self.showSaveAlert = true
                              }))
                    } else {
                        return Alert(title: Text(TextEnum.saveAlertTitle.rawValue), message: Text("Möchtest du ein neues Schnitzel mit Titel \"\(self.title)\" und Beschreibung \"\(self.description)\" erstellen?"),
                                     primaryButton: .default(Text(TextEnum.save.rawValue), action: {
                          self.data.arView.saveSchnitzel(title: self.title, description: self.description)
                          self.showSaveAlert = true
                          self.data.isTakingSnapshot = true
                        }),
                        secondaryButton: .cancel(Text(TextEnum.saveAlertDecline.rawValue), action: {
                          self.showSaveAlert = false
                        }))
                    }
                }
            }.offset(y: -self.value).animation(.spring()).onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) {
                    (notification) in
                    let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    self.value = value.height
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) {
                    _ in self.value = 0
                }
            }
        }.padding(7).padding(.top, -10)
    }
}

struct MapUIView: View {
    @EnvironmentObject var data: DataModel
    
    var body: some View {
        HStack {
            Button(action: {
                self.data.screenState = .SCOREBOARD
            }){ Image("trophy").renderingMode(.original).resizable().frame(width: 40.0, height: 40.0).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
            Spacer()
            Button(action: {
                self.data.screenState = .PLACE_SCHNITZEL_AR
            }) {
                if self.data.isVeggie {
                    Text(TextEnum.placeARMais.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())
                } else {
                Text(TextEnum.placeARSchnitzel.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())
                }
            }
        }.padding(7).padding(.top, -10).padding(.trailing, 100).frame(width: UIScreen.main.bounds.size.width, height: 55)
            .alert(isPresented: $data.showStartSearchAlert) {
                let schnitzel = self.data.loadedData.currentSchnitzelJagd!
                if schnitzel.isFound {
                    return Alert(title: Text(self.schnitzelTitle), message: Text(TextEnum.alertFoundMessage.rawValue + "\nBenötigte Zeit: " + StaticFunctions.formatTime(seconds: schnitzel.timePassed)), dismissButton: .cancel(Text(TextEnum.okay.rawValue)))
                } else if !schnitzel.couldUpdate {
                    return Alert(title: Text(self.schnitzelTitle), message: Text(TextEnum.alertLoadMessage.rawValue), dismissButton: .cancel(Text(TextEnum.dismiss.rawValue)))
                }
                return Alert(title: Text(TextEnum.alertTitle.rawValue), message: Text(TextEnum.alertMessage.rawValue),
                             primaryButton: .default(Text(TextEnum.alertAccept.rawValue), action: {
                                if schnitzel.readyForSearch() {
                                    self.data.showStartSearchAlert = false
                                    self.data.screenState = .SEARCH_SCHNITZEL_MAP
                                    self.data.getAvailableHints()
                                    print(self.data.availableHints)
                                }
                             }),
                             secondaryButton: .cancel(Text(TextEnum.alertDecline.rawValue), action: {
                                self.data.showStartSearchAlert = false
                             }))
        }
    }
    
    var schnitzelTitle: String {
        self.data.loadedData.currentSchnitzelJagd?.annotationWithRegion.title ?? TextEnum.appTitle.rawValue
    }
    var schnitzelSubtitle: String {
        self.data.loadedData.currentSchnitzelJagd?.annotationWithRegion.subtitle ?? ""
    }
    
}

struct SearchMapUIView: View {
    
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    @State var backgroundColor: Color = Color.blue
    var schnitzelJagd = DataModel.shared.loadedData.currentSchnitzelJagd!
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var currentDistance: Int = 0
    @State var lat: Double = 0.0
    @State var lon: Double = 0.0
    @State var direction: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "hourglass").foregroundColor(.white).font(Font.system(.title))
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: -10))
            Text(StaticFunctions.formatTime(seconds: timePassed))
                .onReceive(timer) { _ in
                    self.handleTimerFired()
            }.font(.headline)
                .padding(8)
                .foregroundColor(.white)
            if self.schnitzelJagd.isFound {
                Text(TextEnum.found.rawValue).fontWeight(.bold).font(.headline).padding(8).foregroundColor(.white)
            }
            Spacer()
            Button(action: {
                self.switchToSearchARMode()
            }) {
                Text(TextEnum.searchAR.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())
            }
            if !self.schnitzelJagd.isFound {
                Button(action: {
                    self.currentDistance = Int (DataModel.shared.loadedData.currentSchnitzelJagd!.determineDistanceToSchnitzel())
                    self.lat = (self.data.location?.coordinate.latitude)!
                    self.lon = (self.data.location?.coordinate.longitude)!
                    self.direction = StaticFunctions.calculateBearing(latitude: self.lat, longitude: self.lon, latTarget: DataModel.shared.loadedData.currentSchnitzelJagd!.annotationWithRegion.coordinate.latitude, lonTarget: DataModel.shared.loadedData.currentSchnitzelJagd!.annotationWithRegion.coordinate.longitude)
                    self.data.showHint()
                })
                {
                    Image(systemName: "lightbulb.fill").foregroundColor(.white).font(Font.system(.title))
                }
                .padding(8)
                .alert(isPresented: self.$data.showHintAlert) {
                                switch(self.data.availableHints){
                                case 3:
                                    return Alert(title: Text("Erster Hinweis:"), message: Text("Das Suchgebiet wurde verkleinert"),
                                    dismissButton: .default(Text("Schließen")))
                                    // Umkreis verkleinern
                                case 2:
                                    return Alert(title: Text("Zweiter Hinweis:"), message: Text("Gehe nach \(self.direction)"),
                                    dismissButton: .default(Text("Schließen")))
                                case 1:
                                    return Alert(title: Text("Letzter Hinweis:"), message: Text("Du bist noch \(self.currentDistance) Meter entfernt"),
                                    dismissButton: .default(Text("Schließen")))
                                default:
                                    return Alert(title: Text("Keine Hinweise mehr verfügbar"),
                                    dismissButton: .default(Text("Schließen")))
                                }
                    }
            }
        }.padding(7).background(self.backgroundColor).frame(width: UIScreen.main.bounds.size.width, height: 55)
    }
    
    func handleTimerFired() {
        if self.schnitzelJagd.isFound {
            self.backgroundColor = .orange
            self.timer.upstream.connect().cancel()
            return
        }
        self.schnitzelJagd.timePassed += 1
        self.timePassed += 1
        let currentDistance = self.schnitzelJagd.determineDistanceToSchnitzel()
        self.backgroundColor = StaticFunctions.getBackgroundColor(distanceToSchnitzel: currentDistance)
        print("currentDistance: \(currentDistance)")
    }
    
    func switchToSearchARMode() {
        if self.schnitzelJagd.worldMap != nil {
            self.data.arView.loadSchnitzel()
            self.data.screenState = .SEARCH_SCHNITZEL_AR
        } else {
            if self.schnitzelJagd.failedLoadingWorldMap {
                print("Sollte nicht passieren, WorldMap konnte nicht geladen werden"); return }
            self.schnitzelJagd.loadWorldMap()
        }
    }
    
}

struct SearchARUIView: View {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    @State var showFoundAlert: Bool = false
    @State var backgroundColor: Color = Color.blue
    @State var helperState: HelperState = .HELPER_INIT
    @State var showReloadAlert: Bool = false
    
    var schnitzelJagd = DataModel.shared.loadedData.currentSchnitzelJagd!
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var currentDistance: Int = 0
    @State var lat: Double = 0.0
    @State var lon: Double = 0.0
    @State var direction: String = ""
    
    var body: some View {
        HStack {
            
            Image(systemName: "hourglass").foregroundColor(.white).font(Font.system(.title))
                 .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: -10))
            Text(StaticFunctions.formatTime(seconds: timePassed))
                .onReceive(timer) { _ in
                    self.handleTimerFired()
            }.font(.headline)
                .padding(8)
                .foregroundColor(.white)
            if self.schnitzelJagd.isFound {
                Text(TextEnum.found.rawValue).fontWeight(.bold).font(.headline).padding(8).foregroundColor(.white)
            }
            Spacer()
            if !self.schnitzelJagd.isFound {
                Button(action: {
                    self.data.showHelperAlert = true
                }){
                    Image("fleisch").renderingMode(.original)
                }.alert(isPresented: self.$data.showHelperAlert) {
                    return self.helperSchnitzelAlert
                }
                Button(action: {
                    self.showReloadAlert = true
                    DataModel.shared.arView.loadSchnitzel()
                }){
                    Image(systemName: "arrow.clockwise.circle")
                        .foregroundColor(.white).font(Font.system(.largeTitle))
                }.padding(8).alert(isPresented: self.$showReloadAlert){
                    return self.reloadAlert
                }
            }
            Button(action: {
                self.data.screenState = .SEARCH_SCHNITZEL_MAP
            }) {
                Text(TextEnum.searchMap.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier(color: .green))
            }.alert(isPresented: self.$showFoundAlert) {
                return self.foundSchnitzelAlert
            }
            if !self.schnitzelJagd.isFound {
                Button(action: {
                    self.currentDistance = Int (DataModel.shared.loadedData.currentSchnitzelJagd!.determineDistanceToSchnitzel())
                    self.lat = (self.data.location?.coordinate.latitude)!
                    self.lon = (self.data.location?.coordinate.longitude)!
                    self.direction = StaticFunctions.calculateBearing(latitude: self.lat, longitude: self.lon, latTarget: DataModel.shared.loadedData.currentSchnitzelJagd!.annotationWithRegion.coordinate.latitude, lonTarget: DataModel.shared.loadedData.currentSchnitzelJagd!.annotationWithRegion.coordinate.longitude)
                    self.data.showHint()
                }){ Image(systemName: "lightbulb.fill").foregroundColor(.white).font(Font.system(.title))
                }.padding(8)
                .alert(isPresented: self.$data.showHintAlert) {
                                switch(self.data.availableHints){
                                case 3:
                                    return Alert(title: Text("Erster Hinweis:"), message: Text("Der Suchradius wurde verkleinert. Wechsel zur Kartenansicht, um das neue Suchgebiet zu sehen"),
                                    dismissButton: .default(Text("Schließen")))
                                    // Umkreis verkleinern
                                case 2:
                                    return Alert(title: Text("Zweiter Hinweis:"), message: Text("Gehe nach \(self.direction)"),
                                    dismissButton: .default(Text("Schließen")))
                                case 1:
                                    return Alert(title: Text("Letzter Hinweis:"), message: Text("Du bist noch \(self.currentDistance) Meter entfernt"),
                                    dismissButton: .default(Text("Schließen")))
                                default:
                                    return Alert(title: Text("Keine Hinweise mehr verfügbar"),
                                    dismissButton: .default(Text("Schließen")))
                                }
                }
            }
        }.padding(7).background(self.backgroundColor).frame(width: UIScreen.main.bounds.size.width, height: 55)
    }
    
    var helperSchnitzelAlert: Alert {
        switch(self.helperState){
        case .HELPER_REQUESTED:
            return Alert(title: Text(TextEnum.helperAlertTitle.rawValue), message: Text(TextEnum.helperAlertMessage.rawValue), primaryButton: .default(Text(TextEnum.load.rawValue), action: {
                self.data.arView.loadHelperSchnitzel()
                self.schnitzelJagd.found()
                self.helperState = .HELPER_LOADING
            }), secondaryButton: .cancel(Text(TextEnum.dismiss.rawValue)))
//        case .HELPER_SUGGESTED:
//            return Alert(title: Text(TextEnum.helperAlertTitle.rawValue), message: Text(TextEnum.helperSuggested.rawValue), dismissButton: .default(Text(TextEnum.okay.rawValue), action: {
//                self.helperState = .HELPER_REQUESTED
//            }))
        case .HELPER_LOADING:
            return Alert(title: Text(TextEnum.helperAlertTitle.rawValue), message: Text(TextEnum.helperLoading.rawValue), dismissButton: .default(Text(TextEnum.okay.rawValue), action: { self.helperState = .HELPER_DONE }))
        default:
            return Alert(title: Text(TextEnum.helperAlertTitle.rawValue), message: Text(TextEnum.helperNotAvailable.rawValue), dismissButton: .default(Text(TextEnum.okay.rawValue)))
        }
    }
    
    var foundSchnitzelAlert: Alert {
        Alert(title: Text(TextEnum.foundAlertTitle.rawValue), message: Text("Glückwunsch! Du hast das Schnitzel \(self.schnitzelJagd.annotationWithRegion.title!) gefunden!\nBenötigte Zeit: " + StaticFunctions.formatTime(seconds: self.timePassed)),
              primaryButton: .default(Text(TextEnum.foundAlertAccept.rawValue), action: {
                self.showFoundAlert = false
                self.data.screenState = .MENU_MAP
              }),
              secondaryButton: .cancel(Text(TextEnum.foundAlertDecline.rawValue), action: {
                self.showFoundAlert = false
              }))
    }
    
    var reloadAlert: Alert {
        Alert(title: Text(TextEnum.reloadAlertTitle.rawValue), message: Text(TextEnum.reloadAlertMessage.rawValue), dismissButton: .default(Text(TextEnum.close.rawValue)))
    }
    
    func handleTimerFired() {
        if self.schnitzelJagd.isFound {
            self.backgroundColor = .orange
            self.timer.upstream.connect().cancel()
            if helperState == .HELPER_LOADING {
                self.data.showHelperAlert = true
            }
            return
        }
        self.schnitzelJagd.timePassed += 1
        self.timePassed += 1
        let currentDistance = self.schnitzelJagd.determineDistanceToSchnitzel()
        self.backgroundColor = StaticFunctions.getBackgroundColor(distanceToSchnitzel: currentDistance)
        print("currentDistance: \(currentDistance)")
        if currentDistance < NumberEnum.foundRadius.rawValue && helperState == .HELPER_INIT {
            self.helperState = .HELPER_REQUESTED
        }
    }
    
}

struct TextModifier: ViewModifier {
    
    var color: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding(8)
            .background(color)
            .cornerRadius(40)
            .foregroundColor(.white)
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.purple, lineWidth: 4)
        )
    }
}

struct TextFieldStyle: ViewModifier {
    var font: Font
    var showPlaceHolder: Bool
    var placeholder: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .font(font)
                    .foregroundColor(.white)
                    .background(Color.clear)
                    .padding(.horizontal, 15)
            }
            content
                .font(font)
                .foregroundColor(.white)
                .background(Color.clear)
                .padding(.horizontal, 15)
        }
    }
}

#endif
