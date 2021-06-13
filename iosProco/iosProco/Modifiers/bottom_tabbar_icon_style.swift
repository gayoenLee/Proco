//
//  botton_tabbar_icon_style.swift
//  proco
//
//  Created by 이은호 on 2020/11/15.
//

import SwiftUI

extension Image{
    
    func bottom_tabbar_icon_style() -> some View {
        self
            .resizable()
            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
            .aspectRatio(contentMode: .fill)

    
    }
}


