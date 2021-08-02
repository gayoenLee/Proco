//
//  KeyboardHieghtModifier.swift
//  proco
//
//  Created by 이은호 on 2021/07/05.
//

import Foundation
import SwiftUI
import Combine

struct KeyboardHieghtModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    var from_tab : Bool = true
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in UIScreen.main.bounds.height*0.23}
       ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(keyboardHeightPublisher) {
                
                self.keyboardHeight =  self.from_tab ? $0-UIScreen.main.bounds.height*0.23:$0-UIScreen.main.bounds.height*0.20}
    }
}

extension View {
    func KeyboardAwarePadding(from_tab : Bool?) -> some View {
        
        ModifiedContent(content: self, modifier: KeyboardHieghtModifier(from_tab: from_tab ?? true))
    }
}
