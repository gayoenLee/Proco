//
//  text_limiter.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/11.
//

import Foundation
import SwiftUI

class text_limiter: ObservableObject{
    private let limit: Int
    @Published var hasReachedLimit = false

    init(limit: Int){
        self.limit = limit
    }
    @Published var value = "" {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
                self.hasReachedLimit = true
            } else {
                self.hasReachedLimit = false
            }
        }
    }
}
