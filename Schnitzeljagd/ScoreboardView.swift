//
//  ScoreboardView.swift
//  Schnitzeljagd
//
//  Created by admin on 10.07.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI
import UIKit
import Firebase



struct ScoreboardView: View {
    
    var userScore = DataModel.shared.userScores
    let userID: String = (Auth.auth().currentUser?.uid)!
    
    var body: some View {
      VStack {
        List(userScore) { userScore in
          VStack(alignment: .leading) {
            if(userScore.id == self.userID){
                Text(userScore.user).font(.headline).foregroundColor(.blue)
            } else {
            Text(userScore.user)
              .font(.headline)
            }
            Text(String(userScore.score))
              .font(.subheadline)
          }
        }
        .onAppear() {
            DataModel.shared.loadScores()
        }
      }
    }
}

struct CustomScrollView<ROOTVIEW>: UIViewRepresentable where ROOTVIEW: View {
    
    var width : CGFloat, height : CGFloat
    let handlePullToRefresh: () -> Void
    let rootView: () -> ROOTVIEW
    
    func makeCoordinator() -> Coordinator<ROOTVIEW> {
        Coordinator(self, rootView: rootView, handlePullToRefresh: handlePullToRefresh)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let control = UIScrollView()
        control.refreshControl = UIRefreshControl()
        control.refreshControl?.addTarget(context.coordinator, action:
            #selector(Coordinator.handleRefreshControl),
                                          for: .valueChanged)

        let childView = UIHostingController(rootView: rootView() )
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        control.addSubview(childView.view)
        return control
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    class Coordinator<ROOTVIEW>: NSObject where ROOTVIEW: View {
        var control: CustomScrollView
        var handlePullToRefresh: () -> Void
        var rootView: () -> ROOTVIEW

        init(_ control: CustomScrollView, rootView: @escaping () -> ROOTVIEW, handlePullToRefresh: @escaping () -> Void) {
            self.control = control
            self.handlePullToRefresh = handlePullToRefresh
            self.rootView = rootView
        }

        @objc func handleRefreshControl(sender: UIRefreshControl) {

            sender.endRefreshing()
            handlePullToRefresh()
           
        }
    }
}


struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
    }
}
