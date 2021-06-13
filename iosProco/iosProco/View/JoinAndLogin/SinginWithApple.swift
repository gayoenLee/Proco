//
//  SinginWithApple.swift
//  proco
//
//  Created by 이은호 on 2021/03/28.
//

import SwiftUI
import AuthenticationServices

final class SignInWithApple: UIViewRepresentable { // 2
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton { // 3
        return ASAuthorizationAppleIDButton()
        
    } // 4
        func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
            
        }
    
}


