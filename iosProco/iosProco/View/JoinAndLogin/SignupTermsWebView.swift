//
//  SignupTermsWebView.swift
//  proco
//
//  Created by 이은호 on 2021/05/23.
//

import UIKit
import SwiftUI
import WebKit
import Foundation


struct SignupTermsWebView: UIViewRepresentable {
    
    let url: URL
    let navigationHelper = WebViewHelper()

    func makeUIView(context: UIViewRepresentableContext<SignupTermsWebView>) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = navigationHelper

        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)

        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<SignupTermsWebView>) {
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
}


class WebViewHelper: NSObject, WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           print("webview didFinishNavigation")
       }
       
       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           print("didStartProvisionalNavigation")
       }
       
       func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
           print("webviewDidCommit")
       }
       
       func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           print("didReceiveAuthenticationChallenge")
           completionHandler(.performDefaultHandling, nil)
       }
}
