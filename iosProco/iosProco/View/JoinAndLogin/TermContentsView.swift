//
//  TermContentsView.swift
//  proco
//
//  Created by 이은호 on 2021/05/23.
// 회원가입 약관동의 웹뷰 띄우는 뷰

import SwiftUI
import WebKit

struct TermContentsView: View {
    
    let url : String
    
    var body: some View {
        SignupTermsWebView(url: URL(string: url)!)
    }
}
