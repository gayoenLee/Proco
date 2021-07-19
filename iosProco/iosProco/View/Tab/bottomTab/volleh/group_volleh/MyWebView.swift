//
//  MyWebView.swift
//  proco
//
//  Created by 이은호 on 2021/01/01.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import WebKit
import SwiftyJSON

// MARK: - WebViewHandlerDelegate
// For printing values received from web app
protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
    func receivedStringValueFromWebView(value: String)
}

struct MyWebView: UIViewRepresentable, WebViewHandlerDelegate {
    
    @ObservedObject var vm : GroupVollehMainViewmodel
    var url : String
    @State private var got_send_location : Bool = false
    
    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
        let json_value = JSON(value)
        print("마이 웹 뷰 데이터 제이슨 확인: \(json_value)")
        let address = json_value["address"].stringValue
        let map_lat = json_value["lat"].doubleValue
        let map_lng = json_value["lng"].doubleValue
        
        self.got_send_location = true
        
        if got_send_location && self.vm.is_making&&vm.selected_marker_already == false{
            print("카드 편집아님")
            vm.input_location = address
            vm.response_address = address
            self.vm.map_data.location_name = address
            self.vm.map_data.map_lat = map_lat
            self.vm.map_data.map_lng = map_lng
            
            print("데이터 모델에 넣은 것 확인: \(self.vm.map_data)")
            
        }else if self.vm.is_editing_card && self.vm.is_making&&vm.selected_marker_already == false{
            
            vm.input_location = address
            vm.response_address = address
            self.vm.map_data.location_name = address
            self.vm.map_data.map_lat = map_lat
            self.vm.map_data.map_lng = map_lng
            
        }else if vm.selected_marker_already{
            print("카드 만들기에서 지도 여러번 클릭시")
            self.vm.selected_marker_already = false
        }
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
        print("처음에 got send location : \(self.got_send_location)")
        
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
        
        //웹뷰 로드
        if let url = URL(string: url) {
            //공지사항 웹뷰일 경우 비동기 할 필요가 없어서 바로 실행
                        if self.url == "https://withproco.com/notice"{
                            webView.load(URLRequest(url: url))    //
                        }
                        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 ) {
                webView.load(URLRequest(url: url))    // 지정된 URL 요청 개체에서 참조하는 웹 콘텐츠를로드하고 탐색
            }
        }
        }
        //공지사항 웹뷰일 경우 아래의 지도 웹뷰 처리를 할 필요가 없어서 바로 웹뷰 리턴
                if self.url == "https://withproco.com/notice"{
                    return webView
                }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            
            if self.got_send_location{
                print("make ui view에서 got send location 트루인 경우")
                webView.evaluateJavaScript("marker_set('\(self.vm.map_data.map_lat)','\(self.vm.map_data.map_lng)')", completionHandler: { (value, error) in
                    
                    // .. do anything needed with result, if any
                    print("makeUIView 222222222 marker_set : \(error)")
                    
                })
            }else if vm.selected_marker_already{
                print("마커 두번째 이상 찍는 경우: \(vm.map_data)")
                webView.evaluateJavaScript("marker_set('\(self.vm.map_data.map_lat)','\(self.vm.map_data.map_lng)')", completionHandler: { (value, error) in
                    
                    // .. do anything needed with result, if any
                    print("makeUIView 222222222 marker_set : \(error)")
                })
                
            }else{
                print("그 외 make ui view ")
            }
        }
        return webView
    }
    
    //업데이트 ui view
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<MyWebView>) {
        
        if self.got_send_location{
            
            uiView.evaluateJavaScript("marker_set('\(self.vm.map_data.map_lat)','\(self.vm.map_data.map_lng)')", completionHandler: { (value, error) in
                
                print("my webview의 updateUIView marker_set 에서 데이터 확인: \(vm.map_data)")
            })
        }
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        @ObservedObject var vm : GroupVollehMainViewmodel
        var parent: MyWebView
        var delegate: WebViewHandlerDelegate?
        var valueSubscriber: AnyCancellable? = nil
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        init(_ uiWebView: MyWebView, vm: GroupVollehMainViewmodel) {
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
                
                print("didFinish 들어옴")
                
                webView.evaluateJavaScript("marker_set('\(self.vm.map_data.map_lat)','\(self.vm.map_data.map_lng)')", completionHandler: { (value, error) in
                    // .. do anything needed with result, if any
                    print("didFinish 에서 데이터 확인: \(self.vm.map_data)")
                    print("didFinish 여기로dgfhjkhtrewq: \(value)")
                    
                })
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
            // This allows the navigation
            decisionHandler(.allow)
        }
    }
}

// MARK: - Extensions
extension MyWebView.Coordinator: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "send_location" {
            if let body = message.body as? [String: Any?] {
                
                if  self.vm.is_making || self.vm.is_just_showing{
                    delegate?.receivedJsonValueFromWebView(value: body)
                    print("my web view 데이터 받음 receivedJsonValueFromWebView : \(body)")
                    
                    if self.vm.is_editing_card{
                        self.vm.is_making = true
                    }
                }
                else if vm.selected_marker_already{
                    print("그 외 경우")
                    delegate?.receivedJsonValueFromWebView(value: body)
                    print("my web view 데이터 받음 receivedJsonValueFromWebView : \(body)")
                    
                }
                
            } else if let body = message.body as? String {
                delegate?.receivedStringValueFromWebView(value: body)
                print("마커셋에서 데이터 받음 receivedStringValueFromWebView")
                
                
            }
        }else{
            print("메세지 다른 것 받음")
        }
    }
}


