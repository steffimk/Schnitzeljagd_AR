//
//  StyleModifiers.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 12.07.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI

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
