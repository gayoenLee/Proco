//
//  ResponseError.swift
//  proco
//
//  Created by 이은호 on 2020/12/10.
// 에러 처리 클래스

import Foundation

enum ResponseError: Error {
    //인터넷 연결 오류
  case connection
    //토큰에 관한 처리 중 오류
  case authentication(message: String)
  case server(message: String)
}

extension ResponseError {
  var localizedDescription: String {
    switch self {
    case let .authentication(message):
      return message
    case let .server(message: message):
      return message
    case .connection:
      return "인터넷 연결을 확인하세요"
    }
  }
  
  var isAuthenticationError: Bool {
    if case .authentication = self {
      return true
    }
    return false
  }
}
