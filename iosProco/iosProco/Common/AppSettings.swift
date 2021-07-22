//
//  AppSettings.swift
//  proco
//
//  Created by 이은호 on 2021/07/21.
//

import Foundation

struct Settings{
    
    
    struct regex {
        //영어 대소문자 , 특수문자 모두 가능, @가 무조건 있어야 함, @뒤에는 대문자, 소문자, 숫자만 됨.2~64글자만 허용
        static let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        
        static let phone = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        //비밀번호(숫자, 문자, 특수문자 모두 포함 8-18자)
        static let password = "(?=.*[A-Za-z])(?=.*[0-9])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$!%*?&].{8,20}$"
    }
}
