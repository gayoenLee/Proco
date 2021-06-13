//
//  SignInWithAppleButtonView.swift
//  proco
//
//  Created by 이은호 on 2021/03/28.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleButtonView: UIViewRepresentable {
    typealias UIViewType = UIView
    func makeUIView(context: Context) -> UIView
    {
        return ASAuthorizationAppleIDButton()
        
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        //   
    }
    
}
    

struct SignInWithAppleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButtonView()
    }
}
