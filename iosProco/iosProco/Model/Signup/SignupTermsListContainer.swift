//
//  SignupTermsList.swift
//  proco
//
//  Created by 이은호 on 2020/12/02.
//

import Foundation

struct TermsItem: Identifiable, Hashable{
    let id = UUID()
    let title : String
   
}

class SignupTermsListContainer : ObservableObject{
    @Published var terms_items = [TermsItem]()
    
    init() {
        self.terms_items = [
                            TermsItem(title: "이용약관(필수)"),
                            TermsItem(title: "개인정보 수집 및 이용 (필수)"),
                            TermsItem(title: "위치 정보 이용 약관 동의 (필수)"),
                            TermsItem(title: "마케팅 수신 동의 (선택)")
        ]
    }
}
