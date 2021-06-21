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
    var back_btn_img : UIImage = (UIImage(named: "left")?.withRenderingMode(.alwaysOriginal))!
    
    init(ui_img: UIImage, title: String) {
      let coloredAppearance = UINavigationBarAppearance()
        
      coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.configureWithTransparentBackground()
      coloredAppearance.backgroundImage = ui_img
        coloredAppearance.backgroundImageContentMode = .redraw
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.red]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.red]
        //coloredAppearance.backButtonAppearance.configureWithDefault(for: .done)
        coloredAppearance.setBackIndicatorImage(UIImage(named: "left"), transitionMaskImage: UIImage(named: "left"))
       
       
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -80.0), for: .default)
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
  func navigationBarColor(background_img: String, title: String,
                          displayMode : NavigationBarItem.TitleDisplayMode = .automatic) -> some View {
    self.modifier(NavigationBarModifier(ui_img: UIImage(named: "\(background_img)")!, title: title))
  }
}

