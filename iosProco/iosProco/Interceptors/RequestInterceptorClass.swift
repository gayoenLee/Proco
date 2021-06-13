//
//  RequestInterceptor.swift
//  proco
//
//  Created by 이은호 on 2020/12/10.
//

import Foundation
import Alamofire
import Combine
import SwiftUI

//requestinterceptor프로토콜을 따라야 인터셉트해서 토큰 리퀘스트 할 수 있음.
class RequestInterceptorClass : TokenHandler, RequestInterceptor, Authenticator {
    //****************retry limit이란? 이 횟수가 지나고서는 다시 request안함.
    var retryLimit = 3
    
    //********이것의 역할은? 지난 request의 응답과 비교해서 같은응답이면 무시하기 위함.
    var lastProceededResponse: HTTPURLResponse?
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard
            //case1. 같은 response에 대해서 계속 실행되는 것을 막기 위함.
            lastProceededResponse != request.response,
            //3번까지만 재시도
            request.retryCount < retryLimit,
            let statusCode = request.response?.statusCode,
            //토큰이 만료됐다는 오류의 경우 아래에 case2로 감.
            statusCode.isAuthenticationErrorCode()
        
        
        //3번 이후에 재시도 안함.
        else {
            print("리트라이 가드문 lastProceededResponse : \(String(describing: lastProceededResponse))")
            print("인터셉터 retry의 donotretry들어옴")
            return completion(.doNotRetry)
        }
        //case 2.
        lastProceededResponse = request.response
        print("리트라이 case2 응답 : \(String(describing: lastProceededResponse))")
        //Authenticator의 refreshToken 메소드 실행.
        //새로운 액세스 토큰 요청하고 저장하게 됨.-> 성공하면 donotretry
        update_token { isSuccess in
            print("업데이트 토큰 안에 들어옴")
            isSuccess ? completion(.retry) : completion(.doNotRetry)
        }
    }
    
    //처음에 실행되는 메소드. session을 이용해 실행되거나 request시 interceptor을 넣어준다.
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        //urlRequest로 실행됨.
        var urlRequest = urlRequest
        print("adapt에서 헤더 확인 : \(String(describing: urlRequest.allHTTPHeaderFields))")
        let token = TokenHandler.shared.get_access_token()
        print("인터셉터에서 가져온 토큰 확인 : \(String(describing: token))")
        
        
        if let access_token = accessToken{
            print("인터셉터에서 이프문 안 : \(access_token)")
            urlRequest.setValue("Bearer " + access_token, forHTTPHeaderField: "Authorization")
           // urlRequest.headers.add(.authorization(bearerToken: access_token))
            print("헤더 확인 : \(urlRequest.headers)")
            print("헤더 : \(String(describing: urlRequest.allHTTPHeaderFields))")
         completion(.success(urlRequest))
            print("success후의 헤더 확인 : \(String(describing: urlRequest.allHTTPHeaderFields))")
        }
        else {
            completion(.failure(ResponseError.authentication(message: "인터셉터 오류 발생 ")))
            
        }
    }
}
