//
//  ARUIView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI

#if !targetEnvironment(simulator)

protocol CustomUIView {}

protocol CustomUIViewDelegate {
    func customUIView(_ customUIView: CustomUIView, changeBackgroundColor: Bool, distance: Double?)
}

struct PlaceSchnitzelUIView: View, CustomUIView {
    @EnvironmentObject var data: DataModel
    @State var value: CGFloat = 0
    @State var title: String = ""
    @State var description: String = ""
    @State var showSaveAlert: Bool = false
    var delegate: CustomUIViewDelegate?
    
    init (delegate: ContentView){
        self.delegate = delegate
    }
    
    var body: some View {
        HStack {
//            if (self.data.save){
                VStack {
                    TextField("", text: $title).modifier(TextFieldStyle(font: .title, showPlaceHolder: title.isEmpty, placeholder: TextEnum.schnitzelTitlePlaceholder.rawValue))
                    TextField("", text: $description).modifier(TextFieldStyle(font: .callout, showPlaceHolder: description.isEmpty, placeholder: TextEnum.schnitzelDescriptionPlaceholder.rawValue))
                    Button(action: {
                        self.showSaveAlert = true
                        print("ShowSaveAlert is: \(self.showSaveAlert)")
                    }) {
                        Text(TextEnum.save.rawValue)
                            .fontWeight(.bold)
                            .modifier(TextModifier(color: .yellow))
                    }.alert(isPresented: self.$showSaveAlert) {
                        Alert(title: Text(TextEnum.saveAlertTitle.rawValue), message: Text("Möchtest du ein neues Schnitzel mit Titel \"\(self.title)\" und Beschreibung \"\(self.description)\" erstellen?"),
                        primaryButton: .default(Text(TextEnum.saveAlertAccept.rawValue), action: {
                            self.data.saveSchnitzel(title: self.title, description: self.description)
                            self.showSaveAlert = false
                            self.data.screenState = .MENU_MAP
                        }),
                        secondaryButton: .cancel(Text(TextEnum.saveAlertDecline.rawValue), action: {
                            self.showSaveAlert = false
                        }))
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
//            } else {
//                Button(action: {
//                    self.data.loadSchnitzel()
//                    self.data.save = true
//                }){
//                    Text(TextEnum.load.rawValue)
//                        .fontWeight(.bold)
//                        .modifier(TextModifier(color: .gray))
//                }
//            }
            }.padding(7).padding(.top, -10)
    }
}

struct MapUIView: View, CustomUIView {
    @EnvironmentObject var data: DataModel
    var delegate: CustomUIViewDelegate?
    
    init (delegate: ContentView){
        self.delegate = delegate
    }
    
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
                return Alert(title: Text(TextEnum.alertTitle.rawValue), message: Text(TextEnum.alertFoundMessage.rawValue), dismissButton: .cancel(Text(TextEnum.okay.rawValue)))
            } else if !schnitzel.couldUpdate {
                return Alert(title: Text(TextEnum.alertTitle.rawValue), message: Text(TextEnum.alertLoadMessage.rawValue), dismissButton: .cancel(Text(TextEnum.dismiss.rawValue)))
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

}

struct SearchMapUIView: View, CustomUIView {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    @State var showFoundAlert: Bool = false
    var delegate: CustomUIViewDelegate?
    
    init (delegate: ContentView){
        self.delegate = delegate
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Text("Timer: " + StaticFunctions.formatTime(seconds: timePassed))
                 .onReceive(timer) { _ in
                    self.data.loadedData.currentSchnitzelJagd!.timePassed += 1
                    self.timePassed += 1
                    if self.timePassed % Int(NumberEnum.delay.rawValue) == 0 {
                        let currentDistance = self.data.loadedData.currentSchnitzelJagd!.determineDistanceToSchnitzel()
                        print("currentDistance: \(currentDistance)")
                        self.delegate?.customUIView(self, changeBackgroundColor: true, distance: currentDistance)
                        if currentDistance < NumberEnum.foundRadius.rawValue {
                            self.showFoundAlert = true
                            self.timer.upstream.connect().cancel()
                        }
                    }
             }.font(.headline)
              .padding(8)
              .foregroundColor(.white)
            Spacer()
            Button(action: {
                self.data.screenState = .SEARCH_SCHNITZEL_AR
            }) {
                Text(TextEnum.searchAR.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())}
        }.padding(7).padding(.top, -10)
            .alert(isPresented: self.$showFoundAlert) {
                let schnitzel = self.data.loadedData.currentSchnitzelJagd!
                schnitzel.found()
                return Alert(title: Text(TextEnum.foundAlertTitle.rawValue), message: Text("Glückwunsch! Du hast das Schnitzel \(schnitzel.annotationWithRegion.title!) gefunden!\nBenötigte Zeit: " + StaticFunctions.formatTime(seconds: self.timePassed)),
                         primaryButton: .default(Text(TextEnum.foundAlertAccept.rawValue), action: {
                            self.showFoundAlert = false
                            self.data.screenState = .MENU_MAP
                         }),
                         secondaryButton: .cancel(Text(TextEnum.foundAlertDecline.rawValue), action: {
                            self.showFoundAlert = false
                         }))
        }
    }

}

struct SearchARUIView: View, CustomUIView {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    @State var showFoundAlert: Bool = false
    var delegate: CustomUIViewDelegate?
    
    init (delegate: ContentView){
        self.delegate = delegate
    }
       
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text("Timer: " + StaticFunctions.formatTime(seconds: timePassed))
                 .onReceive(timer) { _ in
                    self.data.loadedData.currentSchnitzelJagd!.timePassed += 1
                    self.timePassed += 1
                    if self.timePassed % Int(NumberEnum.delay.rawValue) == 0 {
                        let currentDistance = self.data.loadedData.currentSchnitzelJagd!.determineDistanceToSchnitzel()
                        print("currentDistance: \(currentDistance)")
                        self.delegate?.customUIView(self, changeBackgroundColor: true, distance: currentDistance)
                        if currentDistance < NumberEnum.foundRadius.rawValue {
                            self.showFoundAlert = true
                            self.timer.upstream.connect().cancel()
                        }
                    }
             }.font(.headline)
              .padding(8)
              .foregroundColor(.white)
            Spacer()
            Button(action: {
                self.data.screenState = .SEARCH_SCHNITZEL_MAP
                self.delegate?.customUIView(self, changeBackgroundColor: true, distance: nil)
            }) {
                Text(TextEnum.searchMap.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier(color: .green))
            }
        }.padding(7).padding(.top, -10)
            .alert(isPresented: self.$showFoundAlert) {
                let schnitzel = self.data.loadedData.currentSchnitzelJagd!
                schnitzel.found()
                return Alert(title: Text(TextEnum.foundAlertTitle.rawValue), message: Text("Glückwunsch! Du hast das Schnitzel \(schnitzel.annotationWithRegion.title!) gefunden!\nBenötigte Zeit: " + StaticFunctions.formatTime(seconds: self.timePassed)),
                         primaryButton: .default(Text(TextEnum.foundAlertAccept.rawValue), action: {
                            self.showFoundAlert = false
                            self.data.screenState = .MENU_MAP
                         }),
                         secondaryButton: .cancel(Text(TextEnum.foundAlertDecline.rawValue), action: {
                            self.showFoundAlert = false
                         }))
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
