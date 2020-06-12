//
//  SignInView.swift
//  Schnitzeljagd
//
//  Created by Team Schnitzeljagd on 27.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI

struct SignUpView : View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var loading = false
    @State var error = false
    
    @EnvironmentObject var session: SessionStore
    
    func signUp () {
        print("sign me up")
        loading = true
        error = false
        session.signUp(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                print("\(error)")
                self.error = true
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    
    var body : some View {
        ZStack {
        VStack {
            
            Text("Create an account")
                .font(.title)
                .padding(.horizontal)
                .foregroundColor(.white)
            
            TextField("Email", text: $email)
                .padding()
                .frame(width: 250, height: 30, alignment: .center)
            
            VStack(alignment: .leading) {
                SecureField("Password", text: $password)
                .foregroundColor(.white)
                .padding()
                .frame(width: 250, height: 30, alignment: .center)
                Text("At least 8 characters required.").font(.footnote).foregroundColor(Color.gray)
                .padding()
                }.padding(.horizontal)
            
            if (error) {
                //Alert(
                 //   title: "Hmm... That didn't work.",
                 //   subtitle: "Are you sure you don't already have an account with that email address?"
                //).padding([.horizontal, .top])
               
            }
            
            Button(
                "Sign up",
                action: signUp
                )
                .disabled(loading)
                .padding(5)
                .foregroundColor(.white)
                .background(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00))
                .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00), lineWidth: 5)
                )
                   // alignment: Spacer()
            
        }
            .frame(width: 300, height: 300, alignment: .top)
            .background(Color.black)
            //.overlay(
            //    RoundedRectangle(cornerRadius: 20)
            //        .stroke(Color.white, lineWidth: 15)
            //)
        }
        .frame(width: 500, height: 800, alignment: .center)
        .background(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 0))
        .foregroundColor(.black)
        
    }
    
}

struct SignInView : View {

    @State var email: String = ""
    @State var password: String = ""
    @State var loading = false
    @State var error = false

    @EnvironmentObject var session: SessionStore

    func signIn () {
        loading = true
        error = false
        session.signIn(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
                print("error")
            } else {
                print("success")
                self.email = ""
                self.password = ""
            }
        }
        
    }

    var body: some View {
        NavigationView {
        ZStack {
            VStack {
                
                Text("Log in")
                .font(.title)
                .padding(.horizontal)
                .foregroundColor(.white)
                
                TextField("Email", text: $email)
                    .foregroundColor(.white)
                    .padding(.all)
                    .frame(width: 250, height: 30, alignment: .center)
                
                    
                SecureField("Password", text: $password)
                .foregroundColor(.white)
                .padding()
                .frame(width: 250, height: 30, alignment: .center)
                if (error) {
                    Text("Invalid Credentials").padding(3)
                    .font(.footnote).foregroundColor(Color.gray)
                }
                Button(action: signIn) {
                    Text("Sign in")
                }
                .frame(minWidth: 0, maxWidth: 60)
                .padding(.horizontal, 20)
                .padding(.vertical, 3)
                .background(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00), lineWidth: 8)
                )
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign up")
                            .foregroundColor(Color.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(8)
                    .frame(minWidth: 0, maxWidth: 100)
                
                
            }
            .frame(width: 300, height: 250, alignment: .top)
            .background(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 15)
            )
        }
        .frame(width: 500, height: 1000, alignment: .center)
        .background(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 0))
        .foregroundColor(.white)

    }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
     SignUpView()
    }
}
