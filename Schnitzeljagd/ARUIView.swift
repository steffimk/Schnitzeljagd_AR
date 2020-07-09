//
//  ARUIView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI
import RealityKit

#if !targetEnvironment(simulator)

class UIViews {
    
    private let contentView: ContentView
    private var placeSchnitzelUIView: PlaceSchnitzelUIView?
    private var mapUIView: MapUIView?
    private var searchMapUIView: SearchMapUIView?
    private var searchARUIView: SearchARUIView?
    
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
    
    func refreshAll() {
        self.placeSchnitzelUIView = PlaceSchnitzelUIView()
        self.mapUIView = MapUIView()
        if self.searchMapUIView != nil {
            self.searchMapUIView = SearchMapUIView()
        }
        if self.searchARUIView != nil {
            self.searchARUIView = SearchARUIView()
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
                self.data.screenState = .PLACE_SCHNITZEL_AR
            }) {
                Text(TextEnum.placeAR.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())}
        }.padding(7).padding(.top, -10)
            .alert(isPresented: $data.showStartSearchAlert) {
                let schnitzel = self.data.loadedData.currentSchnitzelJagd!
                if schnitzel.isFound {
                    return Alert(title: Text(self.schnitzelTitle), message: Text(TextEnum.alertFoundMessage.rawValue), dismissButton: .cancel(Text(TextEnum.okay.rawValue)))
                } else if !schnitzel.couldUpdate {
                    return Alert(title: Text(self.schnitzelTitle), message: Text(TextEnum.alertLoadMessage.rawValue), dismissButton: .cancel(Text(TextEnum.dismiss.rawValue)))
                }
                return Alert(title: Text(TextEnum.alertTitle.rawValue), message: Text(TextEnum.alertMessage.rawValue),
                             primaryButton: .default(Text(TextEnum.alertAccept.rawValue), action: {
                                if schnitzel.readyForSearch() {
                                    DataModel.shared.showStartSearchAlert = false
                                    DataModel.shared.screenState = .SEARCH_SCHNITZEL_MAP
                                }
                             }),
                             secondaryButton: .cancel(Text(TextEnum.alertDecline.rawValue), action: {
                                DataModel.shared.showStartSearchAlert = false
                             }))
        }
    }
    
    var schnitzelTitle: String {
        DataModel.shared.loadedData.currentSchnitzelJagd?.annotationWithRegion.title ?? TextEnum.appTitle.rawValue
    }
    var schnitzelSubtitle: String {
        DataModel.shared.loadedData.currentSchnitzelJagd?.annotationWithRegion.subtitle ?? ""
    }
    
}

struct SearchMapUIView: View {
    
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    @State var backgroundColor: Color = Color.blue

    var schnitzelJagd = DataModel.shared.loadedData.currentSchnitzelJagd!
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text("Timer: " + StaticFunctions.formatTime(seconds: timePassed))
                .onReceive(timer) { _ in
                    if self.schnitzelJagd.isFound { self.timer.upstream.connect().cancel(); return}
                    self.schnitzelJagd.timePassed += 1
                    self.timePassed += 1
                    let currentDistance = self.schnitzelJagd.determineDistanceToSchnitzel()
                    self.backgroundColor = StaticFunctions.getBackgroundColor(distanceToSchnitzel: currentDistance)
                    print("currentDistance: \(currentDistance)")
            }.font(.headline)
                .padding(8)
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                if self.schnitzelJagd.worldMap != nil {
                    self.data.arView.loadSchnitzel()
                    self.data.screenState = .SEARCH_SCHNITZEL_AR
                } else {
                    if self.schnitzelJagd.failedLoadingWorldMap {
                        print("Sollte nicht passieren, WorldMap konnte nicht geladen werden"); return }
                    self.schnitzelJagd.loadWorldMap()
                }
            }) {
                Text(TextEnum.searchAR.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())}
        }.padding(7).background(self.backgroundColor)
    }
    
}

struct SearchARUIView: View {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    @State var showAlert: Bool = false
    @State var showFoundAlert: Bool = false
    @State var backgroundColor: Color = Color.blue
    var schnitzelJagd = DataModel.shared.loadedData.currentSchnitzelJagd!
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text("Timer: " + StaticFunctions.formatTime(seconds: timePassed))
                .onReceive(timer) { _ in
                    if self.schnitzelJagd.isFound { self.timer.upstream.connect().cancel(); return}
                    self.schnitzelJagd.timePassed += 1
                    self.timePassed += 1
                    let currentDistance = self.schnitzelJagd.determineDistanceToSchnitzel()
                    self.backgroundColor = StaticFunctions.getBackgroundColor(distanceToSchnitzel: currentDistance)
                    print("currentDistance: \(currentDistance)")
//                    if currentDistance < NumberEnum.foundRadius.rawValue {
//                        self.showFoundAlert = true
//                        self.timer.upstream.connect().cancel()
//                    }
            }.font(.headline)
                .padding(8)
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                self.showAlert = true
            }) {
                Image("fleisch").renderingMode(.original)
            }
            Button(action: {
                DataModel.shared.arView.loadSchnitzel()
            }){
                Image(systemName: "arrow.clockwise.circle").foregroundColor(.white).font(Font.system(.largeTitle))
            }.padding(8)
            Button(action: {
                self.data.screenState = .SEARCH_SCHNITZEL_MAP
            }) {
                Text(TextEnum.searchMap.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier(color: .green))
            }
        }.padding(7).background(self.backgroundColor)
            .alert(isPresented: self.$showAlert) {
                if self.showFoundAlert {
                    self.schnitzelJagd.found()
                    return Alert(title: Text(TextEnum.foundAlertTitle.rawValue), message: Text("Glückwunsch! Du hast das Schnitzel \(self.schnitzelJagd.annotationWithRegion.title!) gefunden!\nBenötigte Zeit: " + StaticFunctions.formatTime(seconds: self.timePassed)),
                                 primaryButton: .default(Text(TextEnum.foundAlertAccept.rawValue), action: {
                                    self.showFoundAlert = false
                                    self.showAlert = false
                                    self.data.screenState = .MENU_MAP
                                 }),
                                 secondaryButton: .cancel(Text(TextEnum.foundAlertDecline.rawValue), action: {
                                    self.showFoundAlert = false
                                    self.showAlert = false
                                 }))
                } else {
                    return Alert(title: Text("Schnitzel manuell laden"), message: Text("Das Schnitzel erscheint nicht, obwohl du die richtige Stelle gefunden hast? Dann lade es jetzt manuell."), primaryButton: .default(Text(TextEnum.load.rawValue), action: {
                        self.showAlert = false
                        self.data.arView.loadHelperSchnitzel()
                        
                    }), secondaryButton: .cancel(Text(TextEnum.dismiss.rawValue), action: {
                        self.showAlert = false
                    }))
                }
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
            .padding(8)
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
