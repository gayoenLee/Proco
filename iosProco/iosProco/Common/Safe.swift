//
//  Safe.swift
//  proco
//
//  Created by 이은호 on 2020/12/24.
//

//import Foundation
//import Combine
//import SwiftUI
//
////// You may keep the following structure in different file or Utility folder. You may rename it properly.
//struct Safe<T: RandomAccessCollection & MutableCollection, C: View>: View {
//
//    typealias BoundElement = Binding<T.Element>
//    private let binding: BoundElement
//    private let content: (BoundElement) -> C
//
//    init(_ binding: Binding<T>, index: T.Index, @ViewBuilder content: @escaping (BoundElement) -> C) {
//        self.content = content
//        self.binding = .init(get: { binding.wrappedValue[index] },
//                             set: { binding.wrappedValue[index] = $0 })
//    }
//
//    var body: some View {
//        content(binding)
//    }
//}
