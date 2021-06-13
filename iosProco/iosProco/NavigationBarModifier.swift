//
//  NavigationBarModifier.swift
//  proco
//
//  Created by 이은호 on 2021/04/28.
//

import Foundation
import SwiftUI

struct NavigationBarModifier : ViewModifier{
    
    var background_img: String?
    var title: String?
    var ui_img : UIImage{
        UIImage(named: "\(String(describing: background_img))")!
    } 
    
    init(ui_img: UIImage, title: String) {
      let coloredAppearance = UINavigationBarAppearance()
        
      coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.configureWithTransparentBackground()
      coloredAppearance.backgroundImage = ui_img
        coloredAppearance.backgroundImageContentMode = .redraw
                     
      UINavigationBar.appearance().standardAppearance = coloredAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
      UINavigationBar.appearance().compactAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
      content
    }
  }

extension View {
  func navigationBarColor(background_img: String, title: String) -> some View {
    self.modifier(NavigationBarModifier(ui_img: UIImage(named: "\(background_img)")!, title: title))
  }
}

