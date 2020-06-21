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
    @State var title: String = "Dein Titel"
    @State var description: String = "Deine Beschreibung"
    var delegate: CustomUIViewDelegate?
    
    init (delegate: ContentView){
        self.delegate = delegate
    }
    
    var body: some View {
        HStack {
            if (self.data.save){
                VStack {
                    TextField("Titel", text: $title).font(.title).foregroundColor(.white).background(Color.clear).padding(.horizontal, 15)
                    TextField("Beschreibung", text: $description).font(.callout).foregroundColor(.white).background(Color.clear).padding(.horizontal, 15)
                    Button(action: {
                        self.data.saveSchnitzel(title: self.title, description: self.description)
                        self.data.save = false
                    }) {
                        Text(TextEnum.save.rawValue)
                            .fontWeight(.bold)
                            .modifier(TextModifier(color: .yellow))
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
            } else {
                Button(action: {
                    self.data.loadSchnitzel()
                    self.data.save = true
                }){
                    Text(TextEnum.load.rawValue)
                        .fontWeight(.bold)
                        .modifier(TextModifier(color: .gray))
                }
            }
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
    }

}

struct SearchMapUIView: View, CustomUIView {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    var delegate: CustomUIViewDelegate?
    
    init (delegate: ContentView){
        self.delegate = delegate
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Text("Timer: \(timePassed)")
                 .onReceive(timer) { _ in
                    self.data.loadedData.currentSchnitzelJagd!.timePassed += 1
                    self.timePassed += 1
                    if self.timePassed % Int(NumberEnum.delay.rawValue) == 0 {
                        let currentDistance = self.data.loadedData.currentSchnitzelJagd!.determineDistanceToSchnitzel()
                        self.delegate?.customUIView(self, changeBackgroundColor: true, distance: currentDistance)
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
    }

}

struct SearchARUIView: View, CustomUIView {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.loadedData.currentSchnitzelJagd!.timePassed
    var delegate: CustomUIViewDelegate?
    
    init (delegate: ContentView){
        self.delegate = delegate
    }
       
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text("Timer: \(timePassed)")
                 .onReceive(timer) { _ in
                    self.data.loadedData.currentSchnitzelJagd!.timePassed += 1
                    self.timePassed += 1
                    if self.timePassed % Int(NumberEnum.delay.rawValue) == 0 {
                        let currentDistance = self.data.loadedData.currentSchnitzelJagd!.determineDistanceToSchnitzel()
                        self.delegate?.customUIView(self, changeBackgroundColor: true, distance: currentDistance)
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

#endif
