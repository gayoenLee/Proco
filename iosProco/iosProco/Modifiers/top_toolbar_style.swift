//
//  top_toolbar_style.swift
//  proco
//
//  Created by 이은호 on 2020/11/15.
//

import SwiftUI

extension Image{
    
    func top_toolbar_icon_style() -> some View {
        self
            .resizable()
            .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
            .aspectRatio(contentMode: .fill)
    }
}
