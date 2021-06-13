//
//  Sessions.swift
//  proco
//
//  Created by 이은호 on 2020/12/10.
//

import Foundation
import Alamofire

class Sessions {
  static let `default` = Sessions().session
    private let session: Session

  private init() {
    session = Session(interceptor: RequestInterceptorClass())
  }
}
