//
//  SmallMapView.swift
//  proco
//
//  Created by 이은호 on 2021/05/02.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import WebKit
import SwiftyJSON


struct SmallMapView: UIViewRepresentable, WebViewHandlerDelegate {
    
    @ObservedObject var vm : GroupVollehMainViewmodel
    var url : String
    
    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
        let json_value = JSON(value)
        print("데이터 제이슨 확인: \(json_value)")

    }
    
    func receivedStringValueFromWebView(value: String) {
        print("String value received from web is: \(value)")
    }
        
    // Make a coordinator to co-ordinate with WKWebView's default delegate functions
    func makeCoordinator() -> Coordinator {
        Coordinator(self, vm: self.vm)
    }
        
   //ui view 만들기
    func makeUIView(context: Context) ->  WKWebView {

        let preferences = WKPreferences()
           preferences.javaScriptCanOpenWindowsAutomatically = false  // JavaScript가 사용자 상호 작용없이 창을 열 수 있는지 여부
           
           let configuration = WKWebViewConfiguration()
           configuration.preferences = preferences
        
        //웹뷰 인스턴스 생성
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        //webView.autoresizingMask
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.navigationDelegate = context.coordinator    // 웹보기의 탐색 동작을 관리하는 데 사용하는 개체
        webView.allowsBackForwardNavigationGestures = true    // 가로로 스와이프 동작이 페이지 탐색을 앞뒤로 트리거하는지 여부
        webView.scrollView.isScrollEnabled = true    // 웹보기와 관련된 스크롤보기에서 스크롤 가능 여부
        webView.evaluateJavaScript("send_location", completionHandler: { (value, error) in
        print("small map view 에서 makeUIView send_location,: \(value), \(error)")
            
       })
   
        //웹뷰 로드
        if let url = URL(string: url) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            webView.load(URLRequest(url: url))    // 지정된 URL 요청 개체에서 참조하는 웹 콘텐츠를로드하고 탐색
        }
        }
        return webView
    }
    
    //업데이트 ui view
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<SmallMapView>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9){
        uiView.evaluateJavaScript("send_location", completionHandler: { (value, error) in
            print("small map view 업데이트 유아이뷰, \(error)")
       
            if vm.map_data.location_name != ""{
            uiView.evaluateJavaScript("marker_set(\(vm.map_data.map_lat),\(vm.map_data.map_lng))", completionHandler: { (value, error) in
            // .. do anything needed with result, if any
            print("small map view updateUIView 에서 데이터 확인: \(vm.map_data)")
        print("small map view updateUIView 여기로dgfhjkhtrewq: \(value), \(error)")
       })
            }
        })
        }
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        @ObservedObject var vm : GroupVollehMainViewmodel
        var parent: SmallMapView
        var delegate: WebViewHandlerDelegate?
        var valueSubscriber: AnyCancellable? = nil
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
   
        init(_ uiWebView: SmallMapView, vm: GroupVollehMainViewmodel) {
            self.parent = uiWebView
           self.vm = vm
            self.delegate = parent
           
        }
        
        deinit {
            valueSubscriber?.cancel()
            webViewNavigationSubscriber?.cancel()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                webView.evaluateJavaScript("send_location", completionHandler: { (value, error) in
                     // .. do anything needed with result, if any
                 print("small map view 여기로j11111111")
                    if self.vm.map_data.location_name != ""{
                    webView.evaluateJavaScript("marker_set(\(self.vm.map_data.map_lat),\(self.vm.map_data.map_lng)", completionHandler: { (value, error) in
                        // .. do anything needed with result, if any
                    print("small map view 여기로222222222")
                   })
                    }
                })
               }
            
            /* An observer that observes 'viewModel.valuePublisher' to get value from TextField and
             pass that value to web app by calling JavaScript function */

            
            // Page loaded so no need to show loader anymore
            self.parent.vm.showLoader.send(false)
        }
        
        /* Here I implemented most of the WKWebView's delegate functions so that you can know them and
         can use them in different necessary purposes */
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            print("small map view 터미네이트")
            // Hides loader
            parent.vm.showLoader.send(false)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("small map view 디드페일")

            // Hides loader
            parent.vm.showLoader.send(false)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print("small map view 디드커밋")
            
            // Shows loader
            parent.vm.showLoader.send(true)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("small map view 디드스타트")
            // Shows loader
            parent.vm.showLoader.send(true)
            self.webViewNavigationSubscriber = self.parent.vm.webViewNavigationPublisher.receive(on: RunLoop.main).sink(receiveValue: { navigation in
                switch navigation {
                    case .backward:
                        if webView.canGoBack {
                            webView.goBack()
                        }
                    case .forward:
                        if webView.canGoForward {
                            webView.goForward()
                        }
                    case .reload:
                        webView.reload()
                    
                }
            })
        }
        
        // This function is essential for intercepting every navigation in the webview
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("small map view 가로채는부분")
            // Suppose you don't want your user to go a restricted site
            // Here you can get many information about new url from 'navigationAction.request.description'
            if let host = navigationAction.request.url?.host {
                if host == "restricted.com" {
                    // This cancels the navigation
                    decisionHandler(.cancel)
                    return
                }
            }
            // This allows the navigation
            decisionHandler(.allow)
        }
    }
}

extension SmallMapView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Make sure that your passed delegate is called
        if message.name == "send_location" {
            if let body = message.body as? [String: Any?] {
                delegate?.receivedJsonValueFromWebView(value: body)
                print("small map view 데이터 받음 receivedJsonValueFromWebView : \(body)")
               
            } else if let body = message.body as? String {
                delegate?.receivedStringValueFromWebView(value: body)
                print("데이터 받음 receivedStringValueFromWebView")

            }
        }
    }
}



