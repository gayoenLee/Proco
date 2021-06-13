//
//  DateFormatter.swift
//  proco
//
//  Created by 이은호 on 2020/12/08.
// 나중에 제거하기

import Foundation
import Combine

extension String{
    
   static func msg_time_formatter(date_string: String) -> String{
        print("msg_time_formatter 받은 날짜: \(date_string)")
        //date 형태의 string받아서 date형식으로 변환 -> 오전, 오후 형식으로 다시 변환
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let converted_date = date_formatter.date(from: date_string)
        print("msg_time_formatter date로 변환한 날짜: \(converted_date)")
        let format = "a hh:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko")
        let converted_string = formatter.string(from: converted_date!)
        print("시간 오전 오후 형식으로 변환한 날짜: \(converted_string)")
        return converted_string
    }
    
    static func date_to_kor_time(date: Date) -> String{
        print("date_to_kor_time 메소드 들어옴")
        let format = "a hh:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko")
        let converted_string = formatter.string(from: date)
        print("date_to_kor_time 오전 오후 형식으로 변환한 날짜: \(converted_string)")
        return converted_string
        
    }
    
    static func time_to_kor_language(date: String) -> String{
        print("받은 시간: \(date)")
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let converted_date = date_formatter.date(from: date)
        print("date로 변환한 날짜: \(converted_date)")
        
//        let format = "yyyy년 MM월 dd일"
//        let formatter = DateFormatter()
//        formatter.dateFormat = format
//        formatter.locale = Locale(identifier: "ko")
//        let converted_string = formatter.string(from: converted_date!)
//        print("날짜 yyyy년 MM월 dd일 형식으로 변환한 날짜: \(converted_string)")
//        return converted_string
        
        
        //date 형태의 string받아서 date형식으로 변환 -> 오전, 오후 형식으로 다시 변환
        let format = "a hh시 mm분"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko")
        let result_date = date_formatter.date(from: date)
        print("date로 변환한 날짜: \(result_date)")
        let string_date = formatter.string(from: result_date!)
        return string_date
    }
    
    static func date_string(date: Date) -> String{
     
        let format = "yyyy-MM-dd"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko")
        let converted_string = formatter.string(from: date)
        print("날짜만 형식으로 변환한 날짜: \(converted_string)")
        return converted_string
    }
    
    static func dot_form_date_string(date_string: String) -> String{
        print("dot_form_date_string 받은 날짜: \(date_string)")
        //date 형태의 string받아서 date형식으로 변환 -> 오전, 오후 형식으로 다시 변환
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let converted_date = date_formatter.date(from: date_string)
        print("dot_form_date_string date로 변환한 날짜: \(converted_date)")
        let format = "yyyy.MM.dd"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko")
        let converted_string = formatter.string(from: converted_date!)
        print("dot_form_date_string 날짜 yyyy.MM.dd 형식으로 변환한 날짜: \(converted_string)")
        return converted_string
    }
    
    static func kor_date_string(date_string: String) -> String{
        print("받은 날짜: \(date_string)")
        //date 형태의 string받아서 date형식으로 변환 -> 오전, 오후 형식으로 다시 변환
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let converted_date = date_formatter.date(from: date_string)
        print("date로 변환한 날짜: \(converted_date)")
        let format = "yyyy년 MM월 dd일"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko")
        let converted_string = formatter.string(from: converted_date!)
        print("날짜 yyyy년 MM월 dd일 형식으로 변환한 날짜: \(converted_string)")
        return converted_string
    }
    
}
