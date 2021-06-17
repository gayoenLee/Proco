//
//  BigMapView.swift
//  proco
//
//  Created by 이은호 on 2021/05/04.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import WebKit
import SwiftyJSON


struct BigMapView: UIViewRepresentable, WebViewHandlerDelegate {
    
    @ObservedObject var vm : GroupVollehMainViewmodel
    var url : String
    @State private var is_editing : Bool = false
    //@State private var second : Bool = false
    
    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
        let json_value = JSON(value)
        print("빅 맵뷰 데이터 제이슨 확인: \(json_value)")
        let address = json_value["address"].stringValue
        let map_lat = json_value["lat"].doubleValue
        let map_lng = json_value["lng"].doubleValue
        
       
        if self.vm.is_editing_card{
            print("빅맵 뷰 second true일 때")
            self.is_editing = true
        }
        if is_editing == false{
            print("카드 편집아님")
            
            vm.response_address = address
            self.vm.map_data.location_name = address
            self.vm.map_data.map_lat = map_lat
            self.vm.map_data.map_lng = map_lng
            print("데이터 모델에 넣은 것 확인: \(self.vm.map_data)")
        }
        else{
            print("데이터 모델에 저장안함.")
        }
    }
    
    func receivedStringValueFromWebView(value: String) {
        print("String value received from web is: \(value)")
    }
    
    func makeCoordinator() -> Coordinator {
        BigMapView.Coordinator(self, vm: self.vm)
    }
    
    //ui view 만들기
    func makeUIView(context: Context) ->  WKWebView {
        print("make ui view 들어옴 url :)")
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false  // JavaScript가 사용자 상호 작용없이 창을 열 수 있는지 여부
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController.add(self.makeCoordinator(), name: "send_location")
        configuration.userContentController.add(self.makeCoordinator(), name: "marker_set('\(self.vm.map_data.map_lat)', '\(self.vm.map_data.map_lng)')")
        
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        
        //웹뷰 인스턴스 생성
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        //webView.autoresizingMask
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.navigationDelegate = context.coordinator    // 웹보기의 탐색 동작을 관리하는 데 사용하는 개체
        webView.allowsBackForwardNavigationGestures = false    // 가로로 스와이프 동작이 페이지 탐색을 앞뒤로 트리거하는지 여부
        webView.scrollView.isScrollEnabled = false    // 웹보기와 관련된 스크롤보기에서 스크롤 가능 여부
        
        if self.vm.is_editing_card{
            print("빅맵뷰 make ui view에서 마커셋 실행")
            webView.evaluateJavaScript("marker_set('\(self.vm.map_data.map_lat)','\(self.vm.map_data.map_lng)')", completionHandler: { (value, error) in
                
                // .. do anything needed with result, if any
                print("빅맵뷰 makeUIView 222222222 marker_set : \(error)")
                
            })
        }
        
        //웹뷰 로드
        if let url = URL(string: url) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 ) {
                webView.load(URLRequest(url: url))    // 지정된 URL 요청 개체에서 참조하는 웹 콘텐츠를로드하고 탐색
            }
            print("웹뷰 로드함")
        }
        return webView
    }
    
    //업데이트 ui view
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<BigMapView>) {
        print("업데이트 ui view 들어옴")
        
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        @ObservedObject var vm : GroupVollehMainViewmodel
        var parent: BigMapView
        var delegate: WebViewHandlerDelegate?
        var valueSubscriber: AnyCancellable? = nil
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        init(_ uiWebView: BigMapView, vm: GroupVollehMainViewmodel) {
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
                
                // .. do anything needed with result, if any
                print("didFinish 들어옴")
                
                if self.parent.is_editing{
                webView.evaluateJavaScript("marker_set('\(self.vm.map_data.map_lat)','\(self.vm.map_data.map_lng)')", completionHandler: { (value, error) in
                    // .. do anything needed with result, if any
                    print("didFinish 에서 데이터 확인: \(self.vm.map_data)")
                    print("didFinish 여기로dgfhjkhtrewq: \(value)")
                    //self.vm.is_making = true
                    
                })
                }
                
            }
            self.parent.vm.showLoader.send(false)
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            print("하이드")
            parent.vm.showLoader.send(false)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("didFail")
            parent.vm.showLoader.send(false)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print("didCommit")
            parent.vm.showLoader.send(true)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("didStartProvisionalNavigation")
            
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
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("가로채는부분")
            
            if let host = navigationAction.request.url?.host {
                if host == "restricted.com" {
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}

// MARK: - Extensions
extension BigMapView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "send_location" {
            if let body = message.body as? [String: Any?] {
                
                if  self.vm.is_making || self.vm.is_editing_card{
                    
                    delegate?.receivedJsonValueFromWebView(value: body)
                    print("big map view 데이터 받음 receivedJsonValueFromWebView : \(body)")
                    
                }else{
                    print("그 외 경우")
                }
                
            } else if let body = message.body as? String {
                delegate?.receivedStringValueFromWebView(value: body)
                print("데이터 받음 receivedStringValueFromWebView")
                
            }
        }else{
            print("메세지 다른 것 받음")
        }
    }
}
