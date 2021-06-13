//
//  ChatTabs.swift
//  proco
//
//  Created by 이은호 on 2021/01/07.
//

import SwiftUI

struct ChatTabs<Label: View>: View {
    @Binding var tabs: [String] // The tab titles
    @Binding var selection: Int // Currently selected tab
    let underlineColor: Color // Color of the underline of the selected tab
    // Tab label rendering closure - provides the current title and if it's the currently selected tab
    let label: (String, Bool) -> Label

      @ViewBuilder
    var body: some View {
      // Pack the tabs horizontally and allow them to be scrolled
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .center, spacing: 30) {
          ForEach(tabs, id: \.self) {
            self.tab(title: $0)
          }
        }.padding(.horizontal, UIScreen.main.bounds.width/30) // Tuck the out-most elements in a bit
    }
    }

    private func tab(title: String) -> some View {
      let index = self.tabs.firstIndex(of: title)!
      let isSelected = index == selection
      return Button(action: {
        // Allows for animated transitions of the underline,
        // as well as other views on the same screen
        withAnimation {
           self.selection = index
        }
      }) {
        label(title, isSelected)
          .overlay(
            Rectangle() // The line under the tab
                .frame(height: UIScreen.main.bounds.width*0.01)
             // The underline is visible only for the currently selected tab
            .foregroundColor(isSelected ? underlineColor : .clear)
                //.padding(.top, UIScreen.main.bounds.width/30)
            // Animates the tab selection
            .transition(.move(edge: .bottom)) ,alignment: .bottomLeading
          )
      }
    }
  }
