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
    var ui_img : UIImage{
        UIImage(named: "\(String(describing: background_img))")!
    }
//    var btn_img : String?
//    var back_btn_img :UIImage{
//        UIImage(named: "\(String(describing: btn_img))")!
//    }
    
    init(ui_img: UIImage) {
      let coloredAppearance = UINavigationBarAppearance()
        
      coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.configureWithTransparentBackground()
      coloredAppearance.backgroundImage = ui_img
        coloredAppearance.backgroundImageContentMode = .redraw
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
//        coloredAppearance.setBackIndicatorImage(back_btn_img, transitionMaskImage: back_btn_img)
  
        coloredAppearance.shadowColor = .clear
        

    UINavigationBar.appearance().standardAppearance = coloredAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
      UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white
        
    }

    func body(content: Content) -> some View {
      
      content
    }
  }

extension View {
    func navigationBarColor(background_img: String) -> some View {
        self.modifier(NavigationBarModifier(ui_img: UIImage(named: "\(background_img)")!))
  }
}

