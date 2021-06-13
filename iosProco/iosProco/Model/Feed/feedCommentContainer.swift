//
//  feedCommentContainer.swift
//  proco
//
//  Created by 이은호 on 2020/11/26.
//

import SwiftUI
import Foundation
import Combine

class feedCommentContainer: ObservableObject {
    @Published var feed_comments = [feed_comment]()
    init(){
        self.feed_comments = [
            feed_comment(title : "가", commentor: "아라",image: "theGoodLifeCoffee", comment: "한 줄인 댓글 내용이에요"),
            feed_comment(title : "나", commentor: "skdif",image: "blackCoffee", comment: "여러줄인 댓글인 경우에요/ 여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요"),
            feed_comment(title: "다", commentor: "아라",image: "hopStorkCoffee", comment: "한 줄인 댓글 내용이에요"),
            feed_comment(title: "fk", commentor: "erter", image: "coffeeShop", comment: "한 줄인 댓글 내용이에요"),
            feed_comment(title: "가", commentor: "아라",image: "nuareCoffee", comment: "한 줄인 댓글 내용이에요"),
            feed_comment(title: "나", commentor: "dfgew", image: "friendsCafe", comment: "한 줄인 댓글 내용이에요"),
            feed_comment(title : "가", commentor: "nfdhe", image: "blackCoffee", comment: "여러줄인 댓글인 경우에요/ 여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요/여러줄인 댓글인 경우에요"),
        ]
    }
}

struct feed_comment: Identifiable, Hashable{
    let id = UUID()
    //피드를 구분할 수 있는 구분자 임시로 넣음
    let title : String
    let commentor : String
    let image : String
    let comment : String
}


