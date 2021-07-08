//
//  ChatDataManager.swift
//  proco
//
//  Created by 이은호 on 2021/01/03.
//

import Foundation
import SQLite3
import Combine
import SwiftUI
import SwiftyJSON

class ChatDataManager : ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    var db : OpaquePointer?
    
    static let shared = ChatDataManager()
    
    //모든 채팅방 idx를 읽어와서 이 리스트에 넣는다.
    @Published var chatroom_idx_list : [Int] = []{
        willSet{
            objectWillChange.send()
        }
    }
    
    //내가 안읽은 메세지 갯수를 구하기 위함.
    @Published var my_idx = UserDefaults.standard.string(forKey: "user_id"){
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var my_nickname = UserDefaults.standard.string(forKey: "nickname"){
        willSet{
            objectWillChange.send()
        }
    }
    /*
     ----------------------------메세지 안읽은 갯수 계산
     */
    //내가 읽은 메세지 idx
    @Published var read_last_message = -1{
        willSet{
            objectWillChange.send()
        }
    }
    @Published var read_start_message = -1{
        willSet{
            objectWillChange.send()
        }
    }
    //해당 채팅방의 마지막 메세지 idx
    @Published var last_message_idx = -1{
        willSet{
            objectWillChange.send()
        }
    }
    //현재 채팅방 메세지의 idx
    @Published var message_idx = -1{
        willSet{
            objectWillChange.send()
        }
    }
    
    //채팅방에서 모든 메세지의 안읽은 갯수 보여주기 위해 메세지들의 idx리스트 만듬, 채팅방 목록에서 안읽은 메세지 개수 보여주기 위해 채팅방 모든 메세지 idx리스트 저장할 때도 사용.
    @Published var message_idx_list : [Int] = []{
        willSet{
            objectWillChange.send()
        }
    }
    
    @Published var user_read_list : [Int] = []{
        willSet{
            objectWillChange.send()
        }
    }
    //현재 채팅방 안에 사람들의 idx리스트 만들어서 소켓에서 처음에 데이터 받을 때 비교용으로 사용.
    @Published var current_chat_user_list : [Int] = []{
        willSet{
            objectWillChange.send()
        }
    }
    
    //채팅 유저들 저장시 server idx저장
    @Published var exist_chatroom_list : [Int] = []{
        willSet{
            objectWillChange.send()
        }
    }
    //통신 1개에서 서버에 server idx 보내야 할 때
    @Published var user_server_idx: Int = -1 {
        didSet{
            objectWillChange.send()
        }
    }
    //안읽은 사람수 구하기(메세지를 보내기, 받기 이벤트에서 사용)
    func unread_num_first(message_idx: Int) -> Int{
        
        print("메세지 보냈을 때 안읽은 사람 구하기: \(message_idx), read last idx리스트: \(self.user_read_list)")
        var unread_num : Int = 0
        
        // user_read_list: 채팅방 참가자들의 read last idx리스트
        for idx in self.user_read_list{
            print("메시지 idx: \(message_idx) vs read last idx: \(idx)")
            
            if idx < message_idx{
                print("안읽은 사람 +1추가")
                unread_num = unread_num + 1
            }
        }
        return unread_num
    }
    
    //마지막 메세지 계산 메소드(처음에 데이터 뿌려줄 때)
    func get_last_num(read_last_idx: Int) -> Int{
        var unread_num : Int = 0
        print("마지막 메세지 계산 메소드 안")
        for idx in self.message_idx_list{
            print("read last idx: \(read_last_idx) vs 채팅방 idx: \(idx)")
            if read_last_idx >= idx{break}
            
            print("안읽은 메세지 +1추가")
            unread_num = unread_num + 1
        }
        print("안읽은 메세지 계산 최종값: \(unread_num)")
        return unread_num
    }
    
    //채팅방 메시지 보낼 때 현재 시간 보내기 위한 메소드, user deleted_at추가할 때 사용
    func get_current_time() -> CLong{
        //time: 현재 시간
        let time = Date().timeIntervalSince1970
        return CLong(time)
    }
    
    //채팅방 메시지 보낼 때 서버에서 보낸 시간 보내기 위한 메소드
    func make_created_at() -> String{
        let time = Date()
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = date_formatter.string(from: time)
        return date
    }
    
    //------------------------------------------
    init(){
        db = open_db()
    }
    
    //디비파일 경로
    private var db_path: String{
        return try! FileManager.default
            .url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(String(describing: self.my_idx!)).db")
            .path
    }
    
    // 디비 연결하기
    func open_db() ->  OpaquePointer?{
        var db: OpaquePointer? = nil
        
        //파일 경로에 있는 데이터 베이스와 연결 하겠다는 것. 만약에 이미 존재하면 다시 생성하지 않고 넘어감.
        let result = sqlite3_open(self.db_path, &db)
        if result == SQLITE_OK{
            print("디비 연결됨")
            print("디비 열어서 경로 확인: \(self.db_path)")
            return db
        }else{
            print("디비 연결 안됨")
        }
        return nil
    }
    
    //디비 닫기
    private func close_db(_ pointer: OpaquePointer?){
        if pointer != nil{
            sqlite3_close(pointer!)
        }
    }
    //소켓 처음 연결시 모든 채팅방 idx리스트 가져오기
    func get_all_chatroom_idx()-> Int{
        open_db()
        chatroom_idx_list.removeAll()
        
        let query = "SELECT idx FROM CHAT_ROOM"
        var stmt: OpaquePointer? = nil
        var idx = 000
        let error  = String(cString: sqlite3_errmsg(stmt))

        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK {
            //현재 테이블에서 컬럼이 존재하면 계속 읽는다는 것.
            while sqlite3_step(stmt) == SQLITE_ROW{
                
                //0은 첫번째 컬럼을 말함.
                idx = Int(sqlite3_column_int(stmt,0))
                print("채팅방 목록 채팅방 idx 가져올 때 확인: \(idx)")
                
                self.chatroom_idx_list.append(idx)
                print("채팅방 목록 채팅방 idx 리스트에 저장했는지 확인: \(self.chatroom_idx_list)")
            }
            
        }else{
            print("채팅방 목록 채팅방 idx 가져오는데 에러: \(error)")
            idx = 000
        }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
        return idx
    }
    
    //채팅방 종류별 채팅방 idx 가져와서 리스트에 넣기
    func get_kinds_chatroom_idx(kinds: String, user_idx: Int)-> Int{
        print("방 종류 가져오기 확인: \(kinds)")
        var query : String = ""
        
        //모임일 경우 온,오프라인 구분 추가로 해줘야 하므로 쿼리가 다름.
        if kinds == "모임"{
         query = """
        SELECT
       CHAT_ROOM.kinds, CHAT_ROOM.idx, CHAT_ROOM.deleted_at, CHAT_ROOM.state, CHAT_ROOM.room_name,CHAT_CARD.expiration_at
        FROM CHAT_USER
         LEFT JOIN CHAT_ROOM
        ON CHAT_USER.chatroom_idx = CHAT_ROOM.idx
         LEFT JOIN CHAT_CARD
        ON CHAT_ROOM.idx = CHAT_CARD.chatroom_idx
         WHERE CHAT_ROOM.kinds IN('온라인 모임', '오프라인 모임') AND CHAT_USER.user_idx = \(user_idx) AND (CHAT_USER.deleted_at IS NULL OR CHAT_USER.deleted_at = '')
"""
        }else{
            query = """
           SELECT
                  CHAT_ROOM.kinds, CHAT_ROOM.idx, CHAT_ROOM.deleted_at, CHAT_ROOM.state, CHAT_ROOM.room_name,CHAT_CARD.expiration_at
           FROM CHAT_USER
            LEFT JOIN CHAT_ROOM
           ON CHAT_USER.chatroom_idx = CHAT_ROOM.idx
            LEFT JOIN CHAT_CARD
           ON CHAT_ROOM.idx = CHAT_CARD.chatroom_idx
            WHERE CHAT_ROOM.kinds = '\(kinds)' AND CHAT_USER.user_idx = \(user_idx) AND (CHAT_USER.deleted_at IS NULL OR CHAT_USER.deleted_at = '')
   """
        }
        print("방 종류 쿼리문 확인 : \(query)")
        var stmt: OpaquePointer? = nil
        var kinds = ""
        var idx = 000
        var deleted_at: String? = ""
        var state = 0
        var expiration_at: String? = ""
        var room_name: String? = ""
        let error  = String(cString: sqlite3_errmsg(stmt))
        let today = Date()
        let calendar = Calendar.current
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK {
            //현재 테이블에서 컬럼이 존재하면 계속 읽는다는 것.
            while sqlite3_step(stmt) == SQLITE_ROW{
                print(" 채팅방 목록 : \(kinds) ")
                //deleted at과 expiration 날짜 차이값 저장할 파라미터
                var deleted_day_distance: Int? = -1
                var expiration_day_distance: Int? = -1
                
                //0. kinds가져오는 것(0은 첫번째 컬럼을 말함.)
                let kinds_query = sqlite3_column_text(stmt, 0)
                if let kinds_query =  kinds_query{
                    kinds = String(cString: kinds_query)
                }else{
                    kinds = ""
                }
                //1. 채팅방 idx
                idx = Int(sqlite3_column_int(stmt,1))
                print("채팅방 목록 채팅방 idx 가져올 때 확인: \(idx)")
                //2.deleted at
                 let deleted_at_query_result = sqlite3_column_text(stmt, 2)
                
                if let deleted_at_query_result =  deleted_at_query_result{
                    deleted_at = String(cString: deleted_at_query_result)
                }else{
                    deleted_at = ""
                }
                
                //3.state
                state = Int(sqlite3_column_int(stmt,3))
                //4.room name
                let roomname_query = sqlite3_column_text(stmt, 4)
                
                if let roomname_query = roomname_query{
                    room_name = String(cString: roomname_query)
                }else{
                    room_name = ""
                }
                
                //deleted at 조건 필터링하기위해 date형식 변환.
                let date_deleted = SockMgr.socket_manager.string_to_date(expiration: deleted_at ?? "")
                //날짜 차이 계산
                deleted_day_distance = calendar.numberOfDaysBetween(date_deleted, and: today)
                
                //일반 채팅방의 경우 카드가 없으므로 expiration at이 없다.
                if kinds != "일반"{
                    //5.expiration at
                    let expiration_at_query_result = sqlite3_column_text(stmt, 5)
                     expiration_at = String(cString: expiration_at_query_result!)
                    
                    //조건 필터링하기위해 date형식 변환.
                    let date_expiration = SockMgr.socket_manager.string_to_date(expiration: expiration_at ?? "")
               
                //날짜 차이 계산
                    expiration_day_distance = calendar.numberOfDaysBetween(date_expiration, and: today)
                
                    deleted_day_distance = calendar.numberOfDaysBetween(date_deleted, and: today)
                    print("계산한 날짜 차이: \(String(describing: expiration_day_distance)), \(String(describing: deleted_day_distance)) ")
                }else{
                    expiration_day_distance = nil
                    print("계산한 날짜 차이: \(String(describing: deleted_day_distance))")
                }

                if (deleted_at == "" || deleted_at == nil || (deleted_day_distance! <= 1 && state == 1)) && (expiration_at == "" || expiration_at == nil || (expiration_day_distance ?? 2 <= 1)){
                    print("조건 충족 : \(String(describing: deleted_at)) \(String(describing: expiration_at))")
                    
                    chatroom_idx_list.append(idx)
                }
                print("채팅방 목록 채팅방 idx 리스트에 저장했는지 확인: \(chatroom_idx_list)")
            }
            print("방 가져오기 while문 밖 : \(error)")
        }else{
            print("채팅방 목록 채팅방 idx 가져오는데 에러: \(error)")
            idx = 000
        }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
        return idx
    }
    
    //1.디비 채팅룸 테이블 만들기
    func create_chatroom_table() {
        //명령을 수행할 db의 c포인터 위치의 주소를 담는 공간.
        var createStatement: OpaquePointer? = nil
        
        let query = "CREATE TABLE IF NOT EXISTS CHAT_ROOM(idx INTEGER, card_idx INTEGER, creator_idx INTEGER, kinds TEXT, room_name TEXT, created_at TEXT, updated_at TEXT, deleted_at TEXT, state INTEGER);"
        
        //-1: 명령어 전체를 읽는다는 것. 확인이 되면 step
        if sqlite3_prepare_v2(self.db, query, -1, &createStatement, nil) == SQLITE_OK{
           
            //complie된 statement실행함
            if sqlite3_step(createStatement) == SQLITE_DONE{
                print("채팅룸 테이블 만들어짐. 성공")
                
            }else{
                let error = String(cString: sqlite3_errmsg(createStatement))
                print("채팅룸 테이블 만드는데 실패:\(error)")
            }
        }else{
            let error  = String(cString: sqlite3_errmsg(createStatement))
            print("채팅룸 테이블 만들 때 에러 발생: \(error)")
        }
        //메모리 제거
        sqlite3_finalize(createStatement)
        sqlite3_close(createStatement)
    }
    
    //2.카드 모델 테이블 만들기
    func create_card_table(){
        //명령을 수행할 db의 c포인터 위치의 주소를 담는 공간.
        var createStatement: OpaquePointer? = nil
        
        let query = "CREATE TABLE IF NOT EXISTS CHAT_CARD(chatroom_idx INTEGER, creator_idx INTEGER, expiration_at TEXT, card_photo_path String, kinds TEXT, lock_state INTEGER, title TEXT, introduce TEXT,  address  TEXT, current_people_count INTEGER, apply_user INTEGER, map_lat Double, map_lng  Double, created_at TEXT, updated_at TEXT, deleted_at TEXT );"
        
        //-1: 명령어 전체를 읽는다는 것. 확인이 되면 step
        if sqlite3_prepare_v2(self.db, query, -1, &createStatement, nil) == SQLITE_OK{
            //complie된 statement실행함
            if sqlite3_step(createStatement) == SQLITE_DONE{
                print("카드 모델 테이블 만들어짐. 성공")
                
            }else{
                let error  = String(cString: sqlite3_errmsg(createStatement))
                print("카드 모델 테이블 만드는데 실패:\(error)")
            }
        }else{
            let error  = String(cString: sqlite3_errmsg(createStatement))
            print("카드 모델 테이블 만들 때 에러 발생: \(error)")
        }
        //메모리 제거
        sqlite3_finalize(createStatement)
        sqlite3_close(createStatement)
        
    }
    
    //3.태그 모델 테이블 만들기
    func create_tag_table(){
        //명령을 수행할 db의 c포인터 위치의 주소를 담는 공간.
        var createStatement: OpaquePointer? = nil
        
        let query = "CREATE TABLE IF NOT EXISTS CHAT_TAG (chatroom_idx INTEGER, tag_idx INTEGER, tag_name TEXT);"
        
        //-1: 명령어 전체를 읽는다는 것. 확인이 되면 step
        if sqlite3_prepare_v2(self.db, query, -1, &createStatement, nil) == SQLITE_OK{
            //complie된 statement실행함
            if sqlite3_step(createStatement) == SQLITE_DONE{
                print("태그 모델 테이블 만들어짐. 성공")
                
            }else{
                let error  = String(cString: sqlite3_errmsg(createStatement))
                print("태그 모델 테이블 만드는데 실패:\(error)")
            }
        }else{
            let error  = String(cString: sqlite3_errmsg(createStatement))
            print("태그 모델 테이블 만들 때 에러 발생: \(error)")
        }
        //메모리 제거
        sqlite3_finalize(createStatement)
        sqlite3_close(createStatement)
        
    }
    //4.유저 테이블 만들기
    func create_user_table(){
        //명령을 수행할 db의 c포인터 위치의 주소를 담는 공간.
        var createStatement: OpaquePointer? = nil
        
        let query = "CREATE TABLE IF NOT EXISTS CHAT_USER(chatroom_idx INTEGER, user_idx INTEGER, nickname TEXT, profile_photo_path TEXT, read_last_idx INTEGER, read_start_idx INTEGER, deleted_at TEXT, temp_key TEXT, server_idx INTEGER, updated_at TEXT);"
        
        //-1: 명령어 전체를 읽는다는 것. 확인이 되면 step
        if sqlite3_prepare_v2(db, query, -1, &createStatement, nil) == SQLITE_OK{
            //complie된 statement실행함
            if sqlite3_step(createStatement) == SQLITE_DONE{
                print("유저 모델 테이블 만들어짐. 성공")
                
            }else{
                let error  = String(cString: sqlite3_errmsg(createStatement))
                print("유저 모델 테이블 만드는데 실패:\(error)")
            }
        }else{
            let error  = String(cString: sqlite3_errmsg(createStatement))
            print("유저 모델 테이블 만들 때 에러 발생: \(error)")
        }
        //메모리 제거
        sqlite3_finalize(createStatement)
        sqlite3_close(createStatement)
    }
    
    //5.채팅모델 테이블 만들기
    func create_chatting_table(){

        //명령을 수행할 db의 c포인터 위치의 주소를 담는 공간.
        var createStatement: OpaquePointer? = nil
        
        let query = "CREATE TABLE IF NOT EXISTS CHAT_CHATTING(chatroom_idx INTEGER, chatting_idx INTEGER, user_idx INTEGER, content TEXT, kinds TEXT, created_at TEXT, front_created_at TEXT);"
        
        //-1: 명령어 전체를 읽는다는 것. 확인이 되면 step
        if sqlite3_prepare_v2(self.db, query, -1, &createStatement, nil) == SQLITE_OK{
            //complie된 statement실행함
            if sqlite3_step(createStatement) == SQLITE_DONE{
                print("채팅모델 테이블 만들어짐. 성공")
                
            }else{
                let error  = String(cString: sqlite3_errmsg(createStatement))
                print("채팅모델 테이블 만드는데 실패:\(error)")
            }
        }else{
            let error  = String(cString: sqlite3_errmsg(createStatement))
            print("채팅모델 테이블 만들 때 에러 발생: \(error)")
        }
        //메모리 제거
        sqlite3_finalize(createStatement)
        sqlite3_close(createStatement)
        
    }
    //--------------------------------------------------------------------
    
    //1.디비 채팅룸 데이터 넣기(친구랑 볼래)
    func insert_chatroom(idx: Int, card_idx: Int, creator_idx: Int, kinds: String, room_name: String, created_at: String, updated_at: String, deleted_at: String, state: Int){
        
        var stmt: OpaquePointer? = nil
        let query = """
            INSERT INTO CHAT_ROOM
            (idx, card_idx, creator_idx, kinds, room_name, created_at, updated_at, deleted_at, state) VALUES(\(idx),\(card_idx),\(creator_idx),'\(kinds)',
            '\(room_name)','\(created_at)','\(updated_at)',
            '\(deleted_at)',\(state));
            """
        let errmsg = String(cString: sqlite3_errmsg(stmt)!)
        print("채팅룸 데이터 넣는 쿼리문 확인: \(query)")
        
            if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
                
                print("채팅 방 목록 데이터 넣는 if문 안에 들어옴")
                switch sqlite3_step(stmt) {
                case SQLITE_ROW:
                    print("유저 데이터 넣는 row")
                    break
                case SQLITE_DONE:
                    print("유저 데이터 넣는 DONE")
                    break
                default:
                    print("유저 데이터 넣는 오류: \(errmsg)")

                }
//
//                sqlite3_bind_int(db, 1, Int32(idx))
//                sqlite3_bind_int(db, 2, Int32(card_idx))
//                sqlite3_bind_int(db, 3, Int32(creator_idx))
//                sqlite3_bind_text(db,4, NSString(string: kinds).utf8String, -1, nil)
//                sqlite3_bind_text(db,5, NSString(string: room_name).utf8String, -1, nil)
//                sqlite3_bind_text(db,6, NSString(string: created_at).utf8String, -1, nil)
//                sqlite3_bind_text(db,7, NSString(string: updated_at).utf8String, -1, nil)
//                sqlite3_bind_text(db,8, NSString(string: deleted_at).utf8String, -1, nil)
//                sqlite3_bind_int(db, 9, Int32(state))

            } else{
                print("데이터 집어넣는 statement없음")
            }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
    }
    
    func insert_chatroom_getchat(idx: Int, card_idx: Int, creator_idx: Int, kinds: String, created_at: String, updated_at: String, deleted_at: String, state: Int){
        
        var db: OpaquePointer? = nil
        let query = "INSERT INTO CHAT_ROOM(idx, card_idx, creator_idx, kinds, created_at, updated_at, deleted_at, state) VALUES(?,?,?,?,?,?,?,?);"
        do{
            if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
                
                print("채팅 방 목록 데이터 넣는 if문 안에 들어옴")
                
                sqlite3_bind_int(db, 1, Int32(idx))
                sqlite3_bind_int(db, 2, Int32(card_idx))
                sqlite3_bind_int(db, 3, Int32(creator_idx))
                sqlite3_bind_text(db,4, NSString(string: kinds).utf8String, -1, nil)
                sqlite3_bind_text(db,5, NSString(string: created_at).utf8String, -1, nil)
                sqlite3_bind_text(db,6, NSString(string: updated_at).utf8String, -1, nil)
                sqlite3_bind_text(db,7, NSString(string: deleted_at).utf8String, -1, nil)
                sqlite3_bind_int(db, 8, Int32(state))

            } else{
                print("데이터 집어넣는 statement없음")
            }
        }
        
        //complie된 statement실행함
        if sqlite3_step(db) == SQLITE_DONE{
            print("데이터 넣음. 성공")
            
        }else{
            print("데이터 넣는데 실패")
        }
        sqlite3_finalize(db)
        sqlite3_close(db)
    }

    //2.카드 데이터 넣기
    func insert_card(chatroom_idx: Int, creator_idx: Int, kinds: String,card_photo_path: String, lock_state: Int,title: String, introduce: String, address: String, map_lat: String, map_lng: String, current_people_count: Int, apply_user: Int, expiration_at: String, created_at: String, updated_at: String, deleted_at: String){
        
        var stmt: OpaquePointer? = nil
        let query = """
            INSERT INTO CHAT_CARD(chatroom_idx, creator_idx, expiration_at,  card_photo_path, kinds,lock_state, title, introduce,  address, map_lat,  map_lng, current_people_count, apply_user, created_at, updated_at, deleted_at)
            VALUES(\(chatroom_idx),\(creator_idx),
            '\(expiration_at)','\(card_photo_path)','\(kinds)',
            \(lock_state),'\(title)','\(introduce)','\(address)',
            '\(map_lat)','\(map_lng)',\(current_people_count),
            \(apply_user),'\(created_at)','\(updated_at)','\(deleted_at)');
            """
        print("카드 데이터 넣는 쿼리문: \(query)")
        let errmsg = String(cString: sqlite3_errmsg(stmt)!)

            if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
                
                print("카드 데이터 넣는 if문 안에 들어옴")
//                sqlite3_bind_int(db, 1, Int32(chatroom_idx))
//                sqlite3_bind_int(db, 2, Int32(creator_idx))
//                sqlite3_bind_text(db, 3, NSString(string: expiration_at).utf8String, -1, nil)
//                sqlite3_bind_text(db, 4, NSString(string: card_photo_path).utf8String, -1, nil)
//                sqlite3_bind_text(db, 5, NSString(string: kinds).utf8String, -1, nil)
//                sqlite3_bind_int(db, 6, Int32(lock_state))
//                sqlite3_bind_text(db, 7, NSString(string: title).utf8String, -1, nil)
//                sqlite3_bind_text(db, 8, NSString(string: introduce).utf8String, -1, nil)
//                sqlite3_bind_text(db, 9, NSString(string: address).utf8String, -1, nil)
//                sqlite3_bind_text(db, 10, NSString(string: map_lat).utf8String, -1, nil)
//                sqlite3_bind_text(db, 11,NSString(string: map_lng).utf8String, -1, nil)
//                sqlite3_bind_int(db, 12, Int32(current_people_count))
//                sqlite3_bind_int(db, 13, Int32(apply_user))
//                sqlite3_bind_text(db, 14, NSString(string: created_at).utf8String, -1, nil)
//                sqlite3_bind_text(db, 15,NSString(string: updated_at).utf8String, -1, nil)
//                sqlite3_bind_text(db, 16, NSString(string: deleted_at).utf8String, -1, nil)
                switch sqlite3_step(stmt) {
                case SQLITE_ROW:
                    print("카드 데이터 넣는 row")
                    break
                case SQLITE_DONE:
                    print("카드 데이터 넣는 DONE")
                    break
                default:
                    print("카드 데이터 넣는 오류: \(errmsg)")
                }
            } else{
                print("카드 데이터 집어넣는 statement없음")
            }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
        
    }
    
    //3.태그 데이터 넣기
    func insert_tag(chatroom_idx: Int, tag_idx: Int, tag_name: String){
        
        var statement: OpaquePointer? = nil
        let query = "INSERT INTO CHAT_TAG(chatroom_idx, tag_idx, tag_name) VALUES(\(chatroom_idx),\(tag_idx),'\(tag_name)');"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        print("태그 데이터 넣는 쿼리문 : \(query)")
            if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
               
                switch sqlite3_step(statement) {
                case SQLITE_ROW:
                    print("태그 데이터 집어넣기 row")
                    print("태그 데이터 넣는 if문 안에 들어옴")
                    break
                case SQLITE_DONE:
                    print("태그 데이터 집어넣기 done")
                    break
                default:
                    print("태그 데이터 집어넣기 에러: \(errmsg)")
                }
            } else{
                print("태그 데이터 집어넣는 오류: \(errmsg)")
            }
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    
    //4.유저 데이터 넣기..temp_key컬럼 추가함.1/18
    func insert_user(chatroom_idx: Int, user_idx: Int, nickname: String, profile_photo_path: String, read_last_idx: Int, read_start_idx: Int, temp_key: String, server_idx: Int, updated_at: String, deleted_at: String ){
       
        var insert_stmt: OpaquePointer? = nil
        let query = """
            INSERT INTO CHAT_USER(chatroom_idx, user_idx, nickname, profile_photo_path , read_last_idx, read_start_idx, temp_key, server_idx, updated_at,deleted_at) VALUES(\(chatroom_idx),\(user_idx),'\(nickname)',
            '\(profile_photo_path)',\(read_last_idx),\(read_start_idx),
            '\(temp_key)',\(server_idx),'\(updated_at)','\(deleted_at)');
            """
        print("디비 유저 데이터 넣기 query: \(query)")
        let errmsg = String(cString: sqlite3_errmsg(insert_stmt)!)
      
            if sqlite3_prepare_v2(self.db, query, -1, &insert_stmt, nil) == SQLITE_OK{
                
                print("유저 데이터 넣는 if문 안에 들어옴")
                switch sqlite3_step(insert_stmt) {
                case SQLITE_ROW:
                    print("유저 데이터 넣는 row")
                    break
                case SQLITE_DONE:
                    print("유저 데이터 넣는 DONE")
                    break
                default:
                    print("유저 데이터 넣는 오류: \(errmsg)")
                }
            } else{
                print("유저 데이터 집어넣는 statement없음")
            }
        sqlite3_finalize(insert_stmt)
        sqlite3_close(insert_stmt)
    }
    
    //5.채팅 메세지 데이터 넣기, 채팅 보낼 때 메시지 임시 저장에 사용
    func insert_chatting(chatroom_idx: Int, chatting_idx: Int, user_idx: Int, content: String, kinds: String, created_at: String, front_created_at: String ){
        
        var statement: OpaquePointer? = nil
        let query = "INSERT INTO CHAT_CHATTING(chatroom_idx, chatting_idx, user_idx, content, kinds , created_at, front_created_at) VALUES(?,?,?,?,?,?,?);"
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("채팅 메세지 데이터 넣는 if문 안에 들어옴")
            print("채팅 메세지 임시 저장시 메세지: \(content)")
            print("채팅 메세지 임시 저장시 front created at: \(front_created_at)")
            
            sqlite3_bind_int(statement, 1, Int32(chatroom_idx))
            sqlite3_bind_int(statement, 2, Int32(chatting_idx))
            sqlite3_bind_int(statement, 3, Int32(user_idx))
            sqlite3_bind_text(statement,4, NSString(string: content).utf8String, -1, nil)
            sqlite3_bind_text(statement,5, NSString(string: kinds).utf8String, -1, nil)
            sqlite3_bind_text(statement,6, NSString(string: created_at).utf8String, -1, nil)
            sqlite3_bind_text(statement,7, NSString(string: front_created_at).utf8String, -1, nil)
            
            let sqliteResult = sqlite3_step(statement)
            if sqliteResult == SQLITE_DONE {
                print("채팅 메세지 데이터 넣는 저장 done")
                //sqlite3_reset(statement)
            }else {
                print("채팅 메세지 데이터 넣는 저장 실패 : \(sqliteResult)")
            }
        } else{
            let errormsg = String(cString: sqlite3_errmsg(statement)!)
            print("채팅 메세지 데이터 집어넣는 오류: \(errormsg)")
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    //--------------------------------------------------------------------
   
    //1. 채팅방 - 채팅 메세지 데이터 업데이트
    func update_chatting_table(chatroom_idx: Int, chatting_idx: Int, user_idx: Int, content: String, kinds: String, created_at: String, front_created_at: String ){
        
        let query = "UPDATE CHAT_CHATTING SET chatting_idx = ?, user_idx= ?, content= ?, kinds= ?, created_at = ?, front_created_at = ? WHERE chatroom_idx=?"
        var db: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(db)!)
        
        do{
            if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
                
                print("채팅 메세지 데이터 넣는 if문 안에 들어옴")
                
                sqlite3_bind_int(db, 1, Int32(chatroom_idx))
                sqlite3_bind_int(db, 2, Int32(chatting_idx))
                sqlite3_bind_int(db, 3, Int32(user_idx))
                
                sqlite3_bind_text(db, 4, NSString(string: content).utf8String, -1, nil)
                sqlite3_bind_text(db, 5, NSString(string: kinds).utf8String, -1, nil)
                sqlite3_bind_text(db, 6, NSString(string: created_at).utf8String, -1, nil)
                sqlite3_bind_text(db, 7, NSString(string: front_created_at).utf8String, -1, nil)
            } else{
                print("채팅 메세지 데이터 집어넣는 오류: \(errormsg)")
            }
        }
        sqlite3_finalize(db)
        sqlite3_close(db)
    }
    
    //2. 채팅방 - 카드 테이블 업데이트
    func update_card_table(chatroom_idx: Int, creator_idx: Int, kinds: String, card_photo_path: String, lock_state: Int,title: String, introduce: String, address: String,map_lat: String, map_lng: String, current_people_count: Int, apply_user: Int, expiration_at: String, created_at: String, updated_at: String, deleted_at: String){
        
        let query = "UPDATE CHAT_CARD SET creator_idx= \(creator_idx), kinds= '\(kinds)', card_photo_path= '\(card_photo_path)', lock_state= \(lock_state), title= '\(title)', introduce= '\(introduce)', address= '\(address)',  map_lat= '\(map_lat)', map_lng= '\(map_lng)', current_people_count= \(current_people_count), apply_user= \(apply_user), expiration_at= '\(expiration_at)', created_at= '\(created_at)', updated_at= '\(updated_at)', deleted_at= '\(deleted_at)' WHERE chatroom_idx = \(chatroom_idx)"
        print("쿼리문 확인: \(query)")
        var stmt: OpaquePointer? = nil
        let errmsg = String(cString: sqlite3_errmsg(stmt)!)
        
            if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
                print("카드 테이블 업데이트 if문 안에 들어옴")
                switch sqlite3_step(stmt) {
                case SQLITE_ROW:
                print("카드 테이블 업데이트sqlite row")
                    break
                case SQLITE_DONE:
                    print("카드 테이블 업데이트 완료")
                    break
                default:
                    print("카드 테이블 업데이트 에러: \(errmsg)")
                }
             
            } else{
                print("카드 테이블 업데이트에러: \(errmsg)")
            }
        
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
    }
    
    //3. 채팅방 - 유저 테이블 업데이트
    func update_user_table(chatroom_idx: Int, user_idx: Int, nickname: String, profile_photo_path: String, read_last_idx: Int, read_start_idx: Int, updated_at: String, deleted_at: String){
        
        open_db()
        let query = "UPDATE CHAT_USER SET nickname= ?, profile_photo_path= ?, read_last_idx= ?, read_start_idx = ? , updated_at = ?, deleted_at = ? WHERE chatroom_idx = ? AND user_idx = ? "
        var update_stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(update_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &update_stmt, nil) == SQLITE_OK{
            
            print("유저 데이터 업데이트하는 데 받은 user_idx: \(user_idx)")
            print("유저 업데이트하는데 받은 read last idx: \(read_last_idx)")
            
            sqlite3_bind_text(update_stmt, 1, NSString(string: nickname).utf8String, -1, nil)
            sqlite3_bind_text(update_stmt, 2, NSString(string: profile_photo_path).utf8String, -1, nil)
            sqlite3_bind_int(update_stmt, 3, Int32(read_last_idx))
            sqlite3_bind_int(update_stmt, 4, Int32(read_start_idx))
            sqlite3_bind_text(update_stmt, 5, NSString(string: updated_at).utf8String, -1, nil)
            sqlite3_bind_text(update_stmt, 6, NSString(string: deleted_at).utf8String, -1, nil)
            sqlite3_bind_int(update_stmt, 7, Int32(chatroom_idx))
            sqlite3_bind_int(update_stmt, 8, Int32(user_idx))
            
            let sqliteResult = sqlite3_step(update_stmt)
            if sqliteResult == SQLITE_DONE {
                print("유저 데이터 업데이트 done")
            }else {
                print("유저 데이터 업데이트 failed : \(sqliteResult)")
                print("유저 업데이트 fail 에러: \(errormsg)")
            }
        }
        sqlite3_finalize(update_stmt)
        sqlite3_close(update_stmt)
    }
   
    
    //4. 디비 채팅룸 - 디비 채팅룸 테이블 업데이트(친구)
    func update_chatroom_table(chatroom_idx: Int, card_idx: Int, creator_idx: Int, kinds: String,created_at: String, updated_at: String, deleted_at: String, state: Int){
        open_db()

        let query = "UPDATE CHAT_ROOM SET card_idx = \(card_idx), creator_idx = \(creator_idx), kinds = '\(kinds)',  created_at = '\(created_at)', updated_at = '\(updated_at)', deleted_at = '\(deleted_at)', state = \(state) WHERE idx= \(chatroom_idx) "
        var update_stmt: OpaquePointer? = nil
        
            if sqlite3_prepare_v2(self.db, query, -1, &update_stmt, nil) == SQLITE_OK{
                
                print("채팅 방 목록 데이터 넣는 if문 안에 들어옴")

                let sqliteResult = sqlite3_step(update_stmt)
                if sqliteResult == SQLITE_DONE {
                    print("채팅 방 목록 업데이트 done")
                }else {
                    print("채팅 방 목록 업데이트 failed : \(sqliteResult)")
                }
            }
        sqlite3_finalize(update_stmt)
        sqlite3_close(update_stmt)
    }
   //카드 수정시 업데이트
    func update_chatroom_card(chatroom_idx: Int, card_idx: Int, creator_idx: Int, kinds: String, created_at: String, updated_at: String, deleted_at: String, room_name: String, state: Int){
    let query = "UPDATE CHAT_ROOM SET card_idx = \(card_idx), creator_idx = \(creator_idx), kinds = '\(kinds)', created_at = '\(created_at)', updated_at = '\(updated_at)', deleted_at = '\(deleted_at)', room_name = '\(room_name)', state = \(state) WHERE idx= \(chatroom_idx) "
    var db: OpaquePointer? = nil
        let errmsg = String(cString: sqlite3_errmsg(db)!)

        if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
            
            switch sqlite3_step(db) {
            case SQLITE_ROW:
            print("카드 수정시 update_chatroom_card 업데이트 row")
                break
            case SQLITE_DONE:
                print("카드 수정시 update_chatroom_card 업데이트완료")
                break
            default:
                print("카드 수정시 update_chatroom_card 업데이트 에러: \(errmsg)")
            }

        } else{
            print("데이터 집어넣는 statement없음")
        }
    
    sqlite3_finalize(db)
    sqlite3_close(db)
}
    
    //5. 채팅방 - 태그 데이터 업데이트하기
    func update_tag_table(chatroom_idx: Int,tag_idx: Int, tag_name: String){
        open_db()
        
        let query = "UPDATE CHAT_TAG SET tag_idx = \(tag_idx), tag_name =  '\(tag_name)' WHERE chatroom_idx = \(chatroom_idx)"
        var statement: OpaquePointer? = nil
        let errmsg = String(cString: sqlite3_errmsg(statement)!)

        do{
            if sqlite3_prepare(self.db, query, -1, &statement, nil) == SQLITE_OK{
               print("태그 데이터 업데이트")
                switch sqlite3_step(statement) {
                case SQLITE_ROW:
                    print("태그 데이터 업데이트 row")
                 
                    break
                case SQLITE_DONE:
                    print("태그 데이터 업데이트 DONE")
                    break
                default:
                    print("태그 데이터 업데이트 오류: \(errmsg)")
                }
            }else{
              
                print("태그 데이터 업데이트 오류: \(errmsg)")
            }
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    
    //유저 테이블 데이터 가져오기. 채팅방 안 드로어에 참여자들 리스트 보여줄 때 사용.
    func read_chat_user(chatroom_idx: Int) {
        SockMgr.socket_manager.user_drawer_struct.removeAll()
        open_db()
        //나가기 이벤트 후 나간 사람은 deleted_at이 추가되는데 이 사람 빼고 가져오는 것
        let query = "SELECT * FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx) AND deleted_at IS ''"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            var count = 0
            print("유저 테이블 데이터 prepare")
            //현재 테이블에서 컬럼이 존재하면 계속 읽는다는 것.
            while sqlite3_step(statement) == SQLITE_ROW{
                
                print("유저 모든 데이터 가져오기 : \(chatroom_idx)")
                //0은 첫번째 컬럼을 말함.
                let chatroom_idx = Int(sqlite3_column_int(statement,0))
                let user_idx = Int(sqlite3_column_int(statement, 1))
                //created_at값이 널일 경우를 체크
                guard let queryResultCol1 = sqlite3_column_text(statement, 2) else {
                    print("유저데이터 가져오는데 nil 임")
                    return
                }
                let nickname = String(cString: queryResultCol1)
                
                //deleted_at이 널일 경우 체크
                guard let queryResultCol2 = sqlite3_column_text(statement, 3) else {
                    print("creator_idx 데이터 가져오는데 nil 임")
                    return
                }
                let profile_photo_path = String(cString: queryResultCol2)
                let read_last_idx = Int(sqlite3_column_int(statement,4))
                let read_start_idx = Int(sqlite3_column_int(statement, 5))
                guard let deleted_at_query = sqlite3_column_text(statement, 6) else {
                    print("deleted_at 데이터 가져오는데 nil 임")
                    return
                }
                let deleted_at = String(cString: deleted_at_query)
                
                SockMgr.socket_manager.user_drawer_struct.append(UserInDrawerStruct(nickname: nickname, profile_photo: profile_photo_path, state: "", user_idx: user_idx, deleted_at: String(deleted_at)))
                
                count = count + 1
            }
            print("유저 테이블 데이터 꺼내오는 것 확인하기: \(SockMgr.socket_manager.user_drawer_struct)")
        }else{
            print("데이터 가져오는데 statement준비 안됨.")
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    
    //디비 채팅룸 데이터 가져오기. 드로어에 카드 정보 보여주기에서 채팅방 종류 알때, 동적링크 채팅방 만든 후 카드 만든 사람 idx 가져올 때
    //동적링크를 보낸 카드의 종류에 따라서 메세지에 이미지 보여주는 것 처리위해 chatroom idx이용해서 chatroom 테이블에서 해당 채팅방 idx의 종류 가져옴.
    func read_chatroom(chatroom_idx: Int) {
        open_db()
        SockMgr.socket_manager.chat_room_struct.removeAll()

        let query = "SELECT * FROM CHAT_ROOM WHERE idx = \(chatroom_idx)"
        var db: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK {

            //현재 테이블에서 컬럼이 존재하면 계속 읽는다는 것.
            if sqlite3_step(db) == SQLITE_ROW{
                
                //0은 첫번째 컬럼을 말함.
                let idx = Int(sqlite3_column_int(db,0))
                print("채팅방 모든 데이터 가져오기 idx: \(idx)")

                let card_idx = Int(sqlite3_column_int(db, 1))
                print("채팅방 모든 데이터 가져오기 card_idx: \(card_idx)")
                let creator_idx = Int(sqlite3_column_int(db, 2))
                print("채팅방 모든 데이터 가져오기 creator_idx: \(creator_idx)")

                //kinds가 널일 경우 체크
                let kinds : String
                let query_result_kinds = sqlite3_column_text(db, 3)
                if let query_result_kinds = query_result_kinds{
                    kinds = String(cString: query_result_kinds)

                }else{
                    kinds = "널임"

                }
                print("채팅방 모든 데이터 가져오기에서 kinds: \(kinds)")
                
                let room_name : String
                //room_name이 널일 경우 체크
                 let query_result_roomname = sqlite3_column_text(db, 4)
                if let query_result_roomname = query_result_roomname{
                    room_name =  String(cString: query_result_roomname)
                }else{
                    room_name =  ""
                }
                
                //created_at값이 널일 경우를 체크
                let created_at : String
                 let query_result_created = sqlite3_column_text(db, 5)
                if let query_result_created = query_result_created{
                    created_at = String(cString: query_result_created)
                }else{
                    created_at = ""
                }
                print("채팅방 모든 데이터 가져오기 created_at: \(created_at)")
                
                let updated_at : String
                let query_result_updated_at = sqlite3_column_text(db, 6)
                if let query_result_updated_at = query_result_updated_at{
                    updated_at = String(cString: query_result_updated_at)
                }else{
                    updated_at = ""
                }
                print("채팅방 모든 데이터 가져오기 updated_at: \(updated_at)")
                
                //deleted_at이 널일 경우 체크
                let deleted_at : String
                let query_result_deleted_at = sqlite3_column_text(db, 7)
                if let query_result_deleted_at = query_result_deleted_at{
                    deleted_at = String(cString: query_result_deleted_at)
                }else{
                    deleted_at = ""
                }
                print("채팅방 모든 데이터 가져오기 deleted_at: \(deleted_at)")
                
                SockMgr.socket_manager.current_chatroom_info_struct.idx = Int(idx)
                SockMgr.socket_manager.current_chatroom_info_struct.card_idx = Int(card_idx)
                SockMgr.socket_manager.current_chatroom_info_struct.created_at = created_at
                SockMgr.socket_manager.current_chatroom_info_struct.creator_idx = Int(creator_idx)
                SockMgr.socket_manager.current_chatroom_info_struct.deleted_at = deleted_at
                SockMgr.socket_manager.current_chatroom_info_struct.kinds = kinds
                print("kinds확인: \( SockMgr.socket_manager.current_chatroom_info_struct.kinds)")
                SockMgr.socket_manager.current_chatroom_info_struct.room_name = room_name
                
                print("read_chatroom 채팅방 데이터 가져와서 저장했는지 확인: \( SockMgr.socket_manager.current_chatroom_info_struct)")
            }
        }else{
            print("read_chatroom 데이터 가져오는데 statement준비 안됨.")
        }
        sqlite3_finalize(db)
        sqlite3_close(db)
    }
    
    /*
     -----------------------------------  친구랑 볼래 - 채팅방 목록 보여주기 위해 데이터 만들기-----------------------------
     안읽은 메세지 제외.
     */
    
    func get_chatroom_last_message(chatroom_idx: Int, kinds: String){
       print("마지막 메세지 가져올 때 채팅방 idx: \(chatroom_idx)")
        /*
         쿼리에서 가져올 것 : 채팅방 idx, 마지막 채팅 메세지, 마지막 채팅 메세지 시간, 방 이름, 주인 이름, 주인 이미지
         쿼리문에서 안가져온 것: 카드 만든 사람(creator_idx이용해서 따로 가져옴),안읽은 메세지 갯수...따로 쿼리 통해서 가져와서 모델에 넣어준다.
         */
        let message_query = """
SELECT CHAT_ROOM.kinds, CHAT_ROOM.idx, CHAT_CHATTING.content, CHAT_CHATTING.created_at, CHAT_ROOM.room_name,CHAT_CHATTING.kinds FROM CHAT_CHATTING INNER JOIN CHAT_ROOM ON CHAT_CHATTING.chatroom_idx = CHAT_ROOM.idx WHERE CHAT_ROOM.idx = \(chatroom_idx) ORDER BY CHAT_CHATTING.front_created_at DESC LIMIT 1
"""
        var get_statement: OpaquePointer? = nil
        let errmsg = String(cString: sqlite3_errmsg(get_statement)!)
        
        if sqlite3_prepare_v2(self.db, message_query, -1, &get_statement, nil) == SQLITE_OK{
            switch sqlite3_step(get_statement) {
            case SQLITE_ROW:
                print("SQLITE_ROW")
                //0. kinds가져오는 것(0은 첫번째 컬럼을 말함.)
                var column_kinds : String
                let kinds_query = sqlite3_column_text(get_statement, 0)
                if let kinds_query =  kinds_query{
                    column_kinds = String(cString: kinds_query)
                }else{
                    column_kinds = ""
                }
                print("채팅방 카드 종류 확인: \(column_kinds)")
                print("마지막 채팅 룸 idx 확인: \(Int(sqlite3_column_int(get_statement,1)))")

                guard let message_query_result = sqlite3_column_text(get_statement, 2) else {
                    print("마지막 메세지 데이터 가져오는데 nil 임")
                    return
                }
                //마지막 채팅 메세지
                var content = String(cString: message_query_result)
                print("마지막 채팅 메세지 확인: \(content)")
                //마지막 채팅 보낸 시간
                let created_at = String(cString:sqlite3_column_text(get_statement,3))
                var room_name : String? = ""
                let roomname_query_result = sqlite3_column_text(get_statement, 4)
                if let roomname_query_result = roomname_query_result{
                    room_name = String(cString:roomname_query_result)
                }else{
                    room_name = ""
                }
                print("룸네임 가져온 것 확인: \(String(describing: room_name))")
                
                //이미지를 보낸 경우 chatting테이블의 kinds가 pd인 경우 따로 메세지를 넣어줘야 함.
                let chatting_kinds = String(cString:sqlite3_column_text(get_statement,5))
                print("채팅메세지 종류 : \(chatting_kinds)")
                
                //이미지를 전송한 경우
                if chatting_kinds == "P"{
                    content = "사진을 보냈습니다."
                }
                //초대링크인 경우
                else if chatting_kinds == "D"{
                    content = "초대링크를 보냈습니다."
                }
                
                    //친구랑 볼래 모델에 데이터 넣기...추가적으로 카드 만든 사람, 안읽은 메세지 갯수
                if kinds == "친구"{
                    print("kinds 친구")
                    SockMgr.socket_manager.friend_chat_model.append(FriendChatRoomListModel(chatroom_idx: chatroom_idx, creator_name: "", room_name: room_name, image: "", last_chat: content, chat_time: created_at, message_num: "", promise_day: "", total_member_num: 0, alarm_state: true, kinds: kinds))
                    print("친구 데이터 넣은 것 확인: \(SockMgr.socket_manager.friend_chat_model)")
                    
                }else if kinds == "모임"{
                    print("kinds 모임")

                    SockMgr.socket_manager.group_chat_model.append(FriendChatRoomListModel(chatroom_idx: chatroom_idx, creator_name: "", room_name: room_name, image: "", last_chat: content, chat_time: created_at, message_num: "", promise_day: "", total_member_num: 0, alarm_state: true, kinds: column_kinds))
                }else{
                    print("kinds 일반")

                    SockMgr.socket_manager.normal_chat_model.append(FriendChatRoomListModel(chatroom_idx: chatroom_idx, creator_name: "", room_name: room_name, image: "", last_chat: content, chat_time: created_at, message_num: "", promise_day: "", total_member_num: 0, alarm_state: true, kinds: column_kinds))
                    print("일반 채팅방 데이터 넣은 것 확인: \( SockMgr.socket_manager.normal_chat_model)")
                }
                break
            case SQLITE_DONE:
                print("get_chatroom_last_message SQLITE_DONE")
                if kinds == "친구"{
                    print("친구일때")
                    SockMgr.socket_manager.friend_chat_model.append(FriendChatRoomListModel(chatroom_idx: chatroom_idx, creator_name: "", room_name: "", image: "", last_chat: "", chat_time: "", message_num: "", promise_day: "", total_member_num: 0, alarm_state: true, kinds: "친구"))
                }else if kinds == "모임"{
                    print("모임일때")
                    
                    SockMgr.socket_manager.group_chat_model.append(FriendChatRoomListModel(chatroom_idx: chatroom_idx, creator_name: "", room_name: "", image: "", last_chat: "", chat_time: "", message_num: "", promise_day: "", total_member_num: 0, alarm_state: true, kinds: ""))
                }else{
                    print("일반일때")
                    SockMgr.socket_manager.normal_chat_model.append(FriendChatRoomListModel(chatroom_idx: chatroom_idx, creator_name: "", room_name: "", image: "", last_chat: "", chat_time: "", message_num: "", promise_day: "", total_member_num: 0, alarm_state: true, kinds: "일반"))
                }
                print("친구 데이터 확인: \(SockMgr.socket_manager.friend_chat_model)")
                break
            default:
                print("error")
                print("그 밖에 오류: \(errmsg)")
            }
        }else{
            print("마지막 메세지 가져오는데 오류: \(errmsg)")
        }
        sqlite3_finalize(get_statement)
        sqlite3_close(get_statement)
    }
    
    /*
     친구랑 볼래 채팅방 목록 - 안읽은 메세지 갯수 가져오기
     안읽은 메세지 갯수 : user에서 내 idx인 것의 read_last_idx가져오기 > chat 모델에서 메세지의 idx와 비교해서 안 읽은 메세지 갯수 구하기
     */
    func get_unread_num(chatroom_idx: Int){
       
        var statement : OpaquePointer? = nil
        let query = "SELECT chatroom_idx, user_idx, read_last_idx FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx) AND user_idx = \(self.my_idx!)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        print("채팅방 idx: \(chatroom_idx)")
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            print("친구랑 볼래 채팅방 안읽은 메세지 prepare들어옴")
           
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                let read_last_idx = Int(sqlite3_column_int(statement, 2))
                
                self.read_last_message = read_last_idx
                print("친구랑 볼래 채팅방 내가 읽은 마지막 메세지 idx확인: \(self.read_last_message)")
            case SQLITE_DONE:
                print("친구랑 볼래 채팅방 내가 읽은 마지막 메세지 idx가져오기 DONE")
                break
            default:
                print("친구랑 볼래 채팅방 내가 읽은 마지막 메세지 idx가져오기 에러: \(errmsg)")
            }
            }else{
                print("친구랑 볼래 채팅방1 안읽은 메세지 갯수 step문 sqlite_row아닌 결과: \(errmsg)")
            }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    
    //현재 채팅방의 메세지 idx리스트 가져오기.
    func get_current_message_num(chatroom_idx: Int, kinds: String){
        
        var select_statement: OpaquePointer? = nil
        let query = "SELECT chatroom_idx, chatting_idx FROM CHAT_CHATTING WHERE chatroom_idx = \(chatroom_idx) ORDER BY CHAT_CHATTING.front_created_at DESC"
        let errormsg = String(cString: sqlite3_errmsg(select_statement)!)
        self.message_idx_list.removeAll()
        print("쿼리문 확인: \(query)")
        let sqlite_result = sqlite3_step(select_statement)

        if sqlite3_prepare_v2(self.db, query, -1, &select_statement, nil) == SQLITE_OK{
            
             while sqlite3_step(select_statement) ==  SQLITE_ROW{
            
                print("현재 채팅방 메세지 idx리스트 가져오기 row")
                let message_idx = Int(sqlite3_column_int(select_statement, 1))
                self.message_idx_list.append(message_idx)
                print("메세지 idx: \(self.message_idx_list)")
           
            }
            
            //읽은 메세지 갯수 계산하는 메소드
            let unread_num =  get_last_num(read_last_idx: self.read_last_message)
            
            if kinds == "친구"{
            //집어넣을 데이터의 index찾기
            let insert_idx = SockMgr.socket_manager.friend_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
            })
            print("채팅방의 마지막 메세지 insert_idx 확인: \(String(describing: insert_idx))")
            
            //안읽은 메세지 갯수 넣음.
            SockMgr.socket_manager.friend_chat_model[insert_idx!].message_num = String(unread_num)
            
            print("친구랑 볼래 채팅방의 안읽은 메세지 갯수 넣은 것 확인: \(SockMgr.socket_manager.friend_chat_model)")
                
            }else if kinds == "모임"{
                //집어넣을 데이터의 index찾기
                let insert_idx = SockMgr.socket_manager.group_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                })
                print("모임 채팅방의 마지막 메세지 insert_idx 확인: \(String(describing: insert_idx))")
                
                //안읽은 메세지 갯수 넣음.
                SockMgr.socket_manager.group_chat_model[insert_idx!].message_num = String(unread_num)
                
                print("모여볼래에서 채팅방의 안읽은 메세지 갯수 넣은 것 확인: \(SockMgr.socket_manager.group_chat_model)")
            }else{
                print("일반 채팅방 데이터 확인: \(SockMgr.socket_manager.normal_chat_model)")
                //집어넣을 데이터의 index찾기
                let insert_idx = SockMgr.socket_manager.normal_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                })
                
                print("일반 채팅방의 마지막 메세지 insert_idx 확인: \(String(describing: insert_idx))")
                
                //안읽은 메세지 갯수 넣음.
                SockMgr.socket_manager.normal_chat_model[insert_idx!].message_num = String(unread_num)
                
                print("일반 채팅방의 안읽은 메세지 갯수 넣은 것 확인: \(SockMgr.socket_manager.normal_chat_model)")
            }
            if sqlite_result == SQLITE_DONE{
                print("현재 채팅방 메세지 idx 리스트 가져옴")
            }else{
                
            }
            
        }else{
            print("get_current_message_num 에러 발생: \(errormsg)")
        }
        sqlite3_finalize(select_statement)
        sqlite3_close(select_statement)
    }
    
    //채팅방 주인 이름 가져오기
    func get_normal_room_friend(chatroom: Int, kinds: String){
        
        let query = "SELECT * FROM CHAT_USER WHERE chatroom_idx = \(chatroom) AND (deleted_at IS NULL OR deleted_at = '') AND user_idx != \(self.my_idx!)"
        
        print("쿼리문 확인: \(query)")
        var name_statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(name_statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &name_statement, nil) == SQLITE_OK{
            print("방 이름 가져오는데 prepare ")
            
            switch sqlite3_step(name_statement) {
            case SQLITE_ROW:
                print("방 이름 가져올 때 채팅방 idx: \(chatroom)")
                
                //0은 첫번째 컬럼을 말함.
                let chatroom_idx = Int(sqlite3_column_int(name_statement,0))
                let user_idx = Int(sqlite3_column_int(name_statement, 1))
                //created_at값이 널일 경우를 체크
                guard let queryResultCol1 = sqlite3_column_text(name_statement, 2) else {
                    print("유저데이터 가져오는데 nil 임")
                    return
                }
                let nickname = String(cString: queryResultCol1)
                
                //deleted_at이 널일 경우 체크
                guard let queryResultCol2 = sqlite3_column_text(name_statement, 3) else {
                    print("creator_idx 데이터 가져오는데 nil 임")
                    return
                }
                    //집어넣을 데이터의 index찾기
                    let insert_idx = SockMgr.socket_manager.normal_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                    })
                    //채팅방 주인 이름, 이미지 넣음
                    SockMgr.socket_manager.normal_chat_model[insert_idx!].creator_name = nickname
                    SockMgr.socket_manager.normal_chat_model[insert_idx!].image = ""
                    print("방 이름 주인 이름, 이미지 넣었는지 확인: \(SockMgr.socket_manager.normal_chat_model[insert_idx!])")
                
            case SQLITE_DONE:
                print("현재 채팅방 메세지 idx리스트 가져오기 done")
                break
            default:
                break
            }
            }else{
            print("마지막 메세지 가져오는데 에러 발생: \(errormsg)")
        }
        sqlite3_finalize(name_statement)
        sqlite3_close(name_statement)
        
    }
    
    //채팅방 주인 이름 가져오기
    func get_creator_info(chatroom: Int, kinds: String){
        
        let query = "SELECT * FROM CHAT_USER WHERE chatroom_idx = \(chatroom) AND (deleted_at IS NULL OR deleted_at = '') "
        var name_statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(name_statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &name_statement, nil) == SQLITE_OK{
            print("방 이름 가져오는데 prepare ")
            
            switch sqlite3_step(name_statement) {
            case SQLITE_ROW:
                print("방 이름 가져올 때 채팅방 idx: \(chatroom)")
                
                //0은 첫번째 컬럼을 말함.
                let chatroom_idx = Int(sqlite3_column_int(name_statement,0))
                let user_idx = Int(sqlite3_column_int(name_statement, 1))
                //created_at값이 널일 경우를 체크
                guard let queryResultCol1 = sqlite3_column_text(name_statement, 2) else {
                    print("유저데이터 가져오는데 nil 임")
                    return
                }
                let nickname = String(cString: queryResultCol1)
                
                //deleted_at이 널일 경우 체크
                guard let queryResultCol2 = sqlite3_column_text(name_statement, 3) else {
                    print("creator_idx 데이터 가져오는데 nil 임")
                    return
                }
                if kinds == "친구"{
                //집어넣을 데이터의 index찾기
                let insert_idx = SockMgr.socket_manager.friend_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                })
                //채팅방 주인 이름, 이미지 넣음
                SockMgr.socket_manager.friend_chat_model[insert_idx!].creator_name = nickname
                SockMgr.socket_manager.friend_chat_model[insert_idx!].image = ""
                print("방 이름 주인 이름, 이미지 넣었는지 확인: \(SockMgr.socket_manager.friend_chat_model[insert_idx!])")
                }else if kinds == "모임"{
                    //집어넣을 데이터의 index찾기
                    let insert_idx = SockMgr.socket_manager.group_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                    })
                    //채팅방 주인 이름, 이미지 넣음
                    SockMgr.socket_manager.group_chat_model[insert_idx!].creator_name = nickname
                    SockMgr.socket_manager.group_chat_model[insert_idx!].image = ""
                    print("방 이름 주인 이름, 이미지 넣었는지 확인: \(SockMgr.socket_manager.group_chat_model[insert_idx!])")
                }else{
                    //집어넣을 데이터의 index찾기
                    let insert_idx = SockMgr.socket_manager.normal_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                    })
                    //채팅방 주인 이름, 이미지 넣음
                    SockMgr.socket_manager.normal_chat_model[insert_idx!].creator_name = nickname
                    SockMgr.socket_manager.normal_chat_model[insert_idx!].image = ""
                    print("방 이름 주인 이름, 이미지 넣었는지 확인: \(SockMgr.socket_manager.normal_chat_model[insert_idx!])")
                }
            case SQLITE_DONE:
                print("현재 채팅방 메세지 idx리스트 가져오기 done")
                break
            default:
                break
            }
            }else{
            print("마지막 메세지 가져오는데 에러 발생: \(errormsg)")
        }
        sqlite3_finalize(name_statement)
        sqlite3_close(name_statement)
        
    }
    
    func get_card_info(chatroom_idx: Int, kinds: String){

        let query = "SELECT * FROM CHAT_CARD WHERE chatroom_idx = \(chatroom_idx)"
        var card_statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(card_statement)!)
        let sqliteResult = sqlite3_step(card_statement)

        if sqlite3_prepare_v2(self.db, query, -1, &card_statement, nil) == SQLITE_OK{
            print("친구랑 볼래 채팅방 이름 가져오는데 prepare ")
            print("친구랑 볼래 채팅방 이름 가져올 때 채팅방 idx: \(chatroom_idx)")
            
            if sqlite3_step(card_statement) == SQLITE_ROW{
                print("친구랑 볼래 채팅방 이름 가져오는 데 step 들어옴")
            
                //0은 첫번째 컬럼을 말함.
                let chatroom_idx = Int(sqlite3_column_int(card_statement,0))
                let creator_idx = Int(sqlite3_column_int(card_statement, 1))
                guard let expiration_query = sqlite3_column_text(card_statement, 2) else {
                    print("친구랑 볼래 채팅방 kinds데이터 가져오는데 nil 임")
                    return
                }
                let expiration_at = String(cString: expiration_query)
                
                //kinds값이 널일 경우를 체크
                guard let kinds_query = sqlite3_column_text(card_statement, 4) else {
                    print("친구랑 볼래 채팅방 kinds데이터 가져오는데 nil 임")
                    return
                }
                let card_kinds = String(cString: kinds_query)
                print("받은 kinds 확인: \(card_kinds)")
                
                let lock_state = Int(sqlite3_column_int(card_statement,5))
                
                //deleted_at이 널일 경우 체크
                guard let title_query = sqlite3_column_text(card_statement, 6) else {
                    print("친구랑 볼래 채팅방 promise_at 데이터 가져오는데 nil 임")
                    return
                }
                let title = String(cString: title_query)
                
                print("친구랑 볼래 채팅방 카드 정보 데이터 확인: lock_state \(lock_state), expiration_at: \(expiration_at)")
            
                if card_kinds == "친구"{
                //집어넣을 데이터의 index찾기
                let insert_idx = SockMgr.socket_manager.friend_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                })
                //채팅방 약속날짜, 모임 제목
                SockMgr.socket_manager.friend_chat_model[insert_idx!].promise_day = expiration_at
                    print("친구랑 볼래 채팅방 약속 날짜 넣었는지 확인: \(String(describing: SockMgr.socket_manager.friend_chat_model[insert_idx!].promise_day))")
                    
                }else{
                    //집어넣을 데이터의 index찾기
                    let insert_idx = SockMgr.socket_manager.group_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx
                    })
                    //채팅방 약속날짜, 모임 제목
                    SockMgr.socket_manager.group_chat_model[insert_idx!].promise_day = expiration_at
                    SockMgr.socket_manager.group_chat_model[insert_idx!].room_name = title
                    
                    print("친구랑 볼래 채팅방 모임 제목 넣었는지 확인: \(title)")
                }
            }else{
                print("친구랑 볼래 채팅방 약속 날짜 가져오는데 step 오류: \(sqlite3_step(card_statement))")
            }
            if sqliteResult == SQLITE_DONE {
                print("친구랑 볼래 채팅방 약속 날짜 가져오는 데 저장 done")
            }else {
                print("친구랑 볼래 채팅방 약속 날짜 가져오는 데 done failed : \(sqliteResult)")
            }
        }else{
            print("친구랑 볼래 채팅방 카드 정보 가져오는데 에러 발생: \(errormsg)")
        }
        sqlite3_finalize(card_statement)
        sqlite3_close(card_statement)
        
        
    }
    
    //채팅방 목록 리스트 데이터 안읽은 메세지, 카드 만든 사람 완성하기
    func set_room_data(kinds: String){
        chatroom_idx_list.removeAll()
        get_kinds_chatroom_idx(kinds: kinds, user_idx: Int(self.my_idx!)!)
        
        print("채팅방 뷰 데이터 만들기 위한 메소드 들어옴 리스트 확인:\(self.chatroom_idx_list)")
        if kinds == "일반"{
            SockMgr.socket_manager.normal_chat_model.removeAll()
            for idx in self.chatroom_idx_list{
                print("일반 채팅방 목록 만들기 : \(idx)")
                self.get_chatroom_last_message(chatroom_idx: idx, kinds: "일반")
                self.get_unread_num(chatroom_idx: idx)
                self.get_current_message_num(chatroom_idx: idx, kinds: "일반")
                self.get_normal_room_friend(chatroom: idx, kinds: "일반")
                self.get_members_in_chatroom(chatroom_idx: idx, kinds: "일반")
                self.set_notify_state(chatroom_idx: idx, kinds: kinds)
                self.read_chat_user(chatroom_idx: idx)
            }
            
            let date_formatter = DateFormatter()
            date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            print("분류 전 일반 채팅방 : \(SockMgr.socket_manager.normal_chat_model)")
            SockMgr.socket_manager.normal_chat_model.sort{
                if $0.chat_time == ""{
                    return false
                }else if $1.chat_time == ""{
                    return true
                }else{
                let first_date = date_formatter.date(from: $0.chat_time!)
                let second_date = date_formatter.date(from: $1.chat_time!)
               return first_date! > second_date!
                }
            }
            print("분류 후 일반 채팅방 : \(SockMgr.socket_manager.normal_chat_model)")

        }else{
            
        for idx in self.chatroom_idx_list{
            print("채팅방 뷰 데이터 만들기 위한 메소드 들어옴 : \(idx)")
            self.get_chatroom_last_message(chatroom_idx: idx, kinds: kinds)
            self.get_unread_num(chatroom_idx: idx)
            self.get_current_message_num(chatroom_idx: idx, kinds: kinds)
            self.get_creator_info(chatroom: idx, kinds: kinds)
            self.get_card_info(chatroom_idx: idx, kinds: kinds)
            self.get_members_in_chatroom(chatroom_idx: idx, kinds: kinds)
            //알림 설정 여부 저장하는 것.
            self.set_notify_state(chatroom_idx: idx, kinds: kinds)
        }
            
            let date_formatter = DateFormatter()
            date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         
            print("분류 전 친구 채팅방 : \(SockMgr.socket_manager.friend_chat_model.map({$0.chat_time}))")
            SockMgr.socket_manager.friend_chat_model.sort{
             
                if $0.chat_time == ""{
                    return false
                }else if $1.chat_time == ""{
                    return true
                }else{
                    let first_date = date_formatter.date(from: $0.chat_time!)
                    let second_date = date_formatter.date(from: $1.chat_time!)
                    return first_date! > second_date!

                }
            }
            print("분류 후 친구 채팅방 : \(SockMgr.socket_manager.friend_chat_model.map({$0.chat_time}))")
            print("분류 전 모임 채팅방 : \(SockMgr.socket_manager.group_chat_model)")
            SockMgr.socket_manager.group_chat_model.sort{
                if $0.chat_time == ""{
                    return false
                }else if $1.chat_time == ""{
                    return true
                }else{
                let first_date = date_formatter.date(from: $0.chat_time!)
                let second_date = date_formatter.date(from: $1.chat_time!)
               return first_date! > second_date!
                }
            }
            print("분류 후 모임 채팅방 : \(SockMgr.socket_manager.group_chat_model)")
            
        }
    }
    
    func set_notify_state(chatroom_idx: Int, kinds: String){
        let my_idx = String(self.my_idx!)
        var notify_state : String = "1"
        notify_state = UserDefaults.standard.string(forKey:  "\(my_idx)_chatroom_alarm_\(chatroom_idx)") ?? "1"
        
        if kinds == "친구"{
          let idx =  SockMgr.socket_manager.friend_chat_model.firstIndex(where: {
                $0.chatroom_idx == chatroom_idx
            })
            if notify_state == "0"{
                SockMgr.socket_manager.friend_chat_model[idx!].alarm_state = false
            }else{
                SockMgr.socket_manager.friend_chat_model[idx!].alarm_state = true
            }

        }else if kinds == "모임"{
            let idx =  SockMgr.socket_manager.group_chat_model.firstIndex(where: {
                  $0.chatroom_idx == chatroom_idx
              })
              if notify_state == "0"{
                  SockMgr.socket_manager.group_chat_model[idx!].alarm_state = false
              }else{
                  SockMgr.socket_manager.group_chat_model[idx!].alarm_state = true
              }
        }else{
            let idx =  SockMgr.socket_manager.normal_chat_model.firstIndex(where: {
                  $0.chatroom_idx == chatroom_idx
              })
              if notify_state == "0"{
                  SockMgr.socket_manager.normal_chat_model[idx!].alarm_state = false
              }else{
                  SockMgr.socket_manager.normal_chat_model[idx!].alarm_state = true
              }
        }
    }

    /*
     ------------------------------------ 테이블 지우는 메소드 시작-------------------------------------
     */
    //특정 채팅 방 메세지 지우기
    func delete_messages(chatroom_idx: Int){

        let query = "DELETE FROM CHAT_CHATTING WHERE chatroom_idx = \(chatroom_idx)"
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("채팅방 메세지 지우는 메소드 prepare안")
            
            if sqlite3_step(statement) == SQLITE_DONE{
                
                print("채팅방 메세지 지우는 메소드 지워짐")
            }else{
                print("채팅방 메세지 지우는 메소드 에러: \(errormsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(statement)
        }
    }
    //디비 채팅룸
    func update_deleted_tables(chatroom_idx: Int){
        open_db()
        let query = "DELETE FROM CHAT_ROOM WHERE idx = \(chatroom_idx)"
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            print("삭제된 채팅방 지우는 메소드 prepare안")

            if sqlite3_step(statement) == SQLITE_DONE{
                
                print("삭제된 채팅방 지우는 메소드 지워짐")
            }else{
                print("삭제된 채팅방 지우는 메소드 지우는 statement 준비 안됨")
            }
            sqlite3_finalize(statement)
        }
    }
    
    //디비 채팅룸

    func delete_chatroom(){
        print("친구랑 볼래 채팅방 지우는 메소드 안")
        let query = "DROP TABLE CHAT_ROOM;"
        var db : OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
            print("친구랑 볼래 지우는 메소드 prepare안")
            
            if sqlite3_step(db) == SQLITE_DONE{
                print("친구랑 볼래지워짐")
            }else{
                print("친구랑 볼래 지우는 statement 준비 안됨")
            }
            sqlite3_finalize(db)
        }
        
    }
    
    func delete_user_table(){
        print("지우는 메소드 안")
        let query = "DROP TABLE CHAT_USER"
        var db : OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
            print("지우는 메소드 prepare안")
            
            if sqlite3_step(db) == SQLITE_DONE{
                print("지워짐")
            }else{
                print("지우는 statement 준비 안됨")
            }
            sqlite3_finalize(db)
        }
    }
    
    func delete_card_table(){
        print("지우는 메소드 안")
        let query = "DROP TABLE CHAT_CARD"
        var db : OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
            print("지우는 메소드 prepare안")
            
            if sqlite3_step(db) == SQLITE_DONE{
                print("지워짐")
            }else{
                print("지우는 statement 준비 안됨")
            }
            sqlite3_finalize(db)
        }
    }
    
    func delete_tag_table(){
        print("지우는 메소드 안")
        let query = "DROP TABLE CHAT_TAG"
        var db : OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
            print("지우는 메소드 prepare안")
            
            if sqlite3_step(db) == SQLITE_DONE{
                print("지워짐")
            }else{
                print("지우는 statement 준비 안됨")
            }
            sqlite3_finalize(db)
        }
    }
    
    func delete_chatting_table(){
        print("지우는 메소드 안")
        let query = "DROP TABLE CHAT_CHATTING"
        var db : OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, query, -1, &db, nil) == SQLITE_OK{
            print("지우는 메소드 prepare안")
            
            if sqlite3_step(db) == SQLITE_DONE{
                print("지워짐")
            }else{
                print("지우는 statement 준비 안됨")
            }
            sqlite3_finalize(db)
            close_db(db)
        }
    }
    
    //디비 채팅룸 친구랑 볼래에서 카드 만든 후 CHAT_ROOM에 채팅방 정보 넣기.
    func insert_chat_info_friend(idx: Int, card_idx: Int, creator_idx: Int, room_name: String, kinds: String){
        
        let query = "INSERT INTO CHAT_ROOM(idx, card_idx, creator_idx, kinds, room_name, created_at) VALUES(\(idx),\(card_idx),\(creator_idx),'\(kinds)','\(room_name)',CURRENT_TIMESTAMP);"
        var statement : OpaquePointer? = nil
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        
            if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
                print("카드 만든 후 chat_room에 데이터 넣음 메소드 prepare안")
                switch sqlite3_step(statement) {
                case SQLITE_ROW:
                print("카드 만들기 sqlite row")
                    break
                case SQLITE_DONE:
                    print("카드 만들기 저장 완료")
                    break
                default:
                    print("카드 만든 후  에러: \(errmsg)")
                }
       
            }
            sqlite3_finalize(statement)
            close_db(statement)
        }
    
  
    //채팅방 입장시 읽음 처리 위해 내 idx가 있는 CHAT_USER정보 가져오기(where chatroom_idx)..채팅방 클릭시
    func get_info_for_unread(chatroom_idx: Int){
                
        var statement : OpaquePointer? = nil
        let query = "SELECT * FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx) AND user_idx = \(self.my_idx!)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            print("채팅방 입장시 get_info_for_unread 내 idx: \(String(describing: self.my_idx)), chatroom_idx: \(chatroom_idx)")
            
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            //이거는 select구문이므로 step문 이용해야함.
            if sqlite3_step(statement) == SQLITE_ROW{
                
                let user_idx = Int(sqlite3_column_int(statement, 1))
                print("채팅방 입장시 읽음 처리 위해 user idx 데이터 가져오는데 확인: \(user_idx)")
                
                guard let nickname_query_result = sqlite3_column_text(statement, 2) else {
                    print("채팅방 입장시 읽음 처리 위해 닉네임 데이터 가져오는데 nil 임")
                    return
                }
                //마지막 채팅 메세지
                let nickname = String(cString: nickname_query_result)
                guard let image_query_result = sqlite3_column_text(statement, 3) else {
                    print("채팅방 입장시 읽음 처리 위해 닉네임 데이터 가져오는데 nil 임")
                    return
                }
                let profile_image = String(cString: image_query_result)
                SockMgr.socket_manager.my_profile_photo = profile_image
                
                let read_last_idx = Int(sqlite3_column_int(statement, 4))
                
                let read_start_idx = Int(sqlite3_column_int(statement, 5))
                self.read_start_message = read_start_idx
                self.read_last_message = read_last_idx
                print("채팅방 입장시 내가 읽은 마지막 메세지 idx확인: \(self.read_last_message)")
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("채팅방 입장시 내가 읽은 마지막 메세지 idx가져옴.") } else { print("채팅방 입장시 내가 읽은 마지막 메세지 idx 못가져옴.") }
            }else{
                print("채팅방 입장시 읽음 처리 위해 안읽은 메세지 갯수 step문 sqlite_row아닌 결과: \(sqlite3_step(statement))")
            }
        }else{
            print("채팅방 입장시 읽음 처리 위해 마지막 메세지 가져오는데 에러 발생: \(errmsg)")
        }
        sqlite3_finalize(statement)
    }
    
    //친구랑 볼래 - 채팅방 읽음 처리 위해서 해당 채팅방의 마지막 메세지의 idx 가져오기(채팅방 1개 클릭시 입장하기 전에)
    func get_last_message_idx(chatroom_idx: Int){
        
        var get_statement : OpaquePointer? = nil
        let query = "SELECT chatting_idx FROM CHAT_CHATTING WHERE chatroom_idx = \(chatroom_idx) ORDER BY front_created_at DESC LIMIT  1"
        let errmsg = String(cString: sqlite3_errmsg(get_statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &get_statement, nil) == SQLITE_OK{
                        
            switch sqlite3_step(get_statement){
            case SQLITE_ROW:
                //Select문에서 가져올 것을 특정한 경우 : 첫번째거는 index가 0
                let message_idx = Int(sqlite3_column_int(get_statement, 0))
                print("마지막 메세지 idx가져왔는지 확인: \(message_idx)")
                self.last_message_idx = message_idx
                break
            case SQLITE_DONE:
                print("마지막 메세지 idx가져옴 done")
                break
             default:
                print("채팅방 입장시 마지막 메세지 idx가져오는데 오류: \(errmsg)")
            }
        }
        sqlite3_finalize(get_statement)
        sqlite3_close(get_statement)
    }
    
    //채팅방 입장시 read_last_idx업데이트하기,채팅 보내기 이벤트에서 read last idx를 새로 보낸 메세지 idx로 업데이트시키기.
    func update_unread_idx(chatroom_idx: Int, read_last_idx: Int){
        var statement : OpaquePointer? = nil
        let query = "UPDATE CHAT_USER SET read_last_idx = \(read_last_idx) WHERE chatroom_idx = \(chatroom_idx) AND user_idx = \(self.my_idx!)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("채팅방 입장시 update_unread_idx 업데이트 처리 chatroom_idx: \(chatroom_idx)")
            print("채팅방 입장시 update_unread_idx 업데이트 처리  read_last_idx: \( read_last_idx)")
            
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            print("채팅방 입장시 update_unread_idx 업데이트 처리 위해 step들어옴")
            
            sqlite3_bind_int(statement, 0, Int32(read_last_idx))
            print("채팅방 입장시 update_unread_idx 업데이트 처리 위해 idx 저장됐는지 확인: \(Int(sqlite3_column_int(statement, 0)))")
            sqlite3_bind_int(statement, 1, Int32(chatroom_idx))
            
            
            if sqlite3_step(statement) == SQLITE_DONE { print("채팅방 입장시 update_unread_idx 업데이트 처리됨.") } else { print("채팅방 입장시 update_unread_idx 업데이트 안됨.") }
        }else{
            print("채팅방 입장시 update_unread_idx prepre 오류: \(errmsg)")
        }
        sqlite3_finalize(statement)
        close_db(statement)
        
    }
    
    //채팅방 입장 후 서버에게서 user_read이벤트 받았을 때 읽음처리, 메세지 보내고 응답 success일 때 메세지 보낸 사람의 reada last idx 해당 메세지로 업데이트
    func update_user_read(chatroom_idx: Int, read_last_idx: Int, user_idx: Int, updated_at : String){
        open_db()
        var statement : OpaquePointer? = nil
        let query = """
            UPDATE CHAT_USER SET read_last_idx = \(read_last_idx), updated_at = '\(updated_at)' WHERE chatroom_idx = \(chatroom_idx) AND user_idx = \(user_idx)
            """
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        print("읽은 마지막 메세지 업데이트 하기위해 update_user_read에서 받은 read_last idx: \(read_last_idx), updated_at: \(updated_at)")
        print("update_user_read query: \(query)")
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("채팅방 입장시 update_user_read 업데이트 처리 user_idx: \(user_idx)")
            print("채팅방 입장시update_user_read  업데이트 처리  read_last_idx: \( read_last_idx)")
            
            switch sqlite3_step(statement) {
                case SQLITE_ROW:
              print("채팅방 입장시 update user read sqlite row")
                    break
            case SQLITE_DONE:
                print("채팅방 입장시 update_user_read 업데이트됨.")
            break
                default:
            print("채팅방 입장시 update_user_read 업데이트 처리 위해 마지막 메세지 가져오는데 에러 발생: \(errmsg)")
                    
        }
        }
        sqlite3_finalize(statement)
    }
    
    /*
     채팅 메세지 채팅창에 뿌리기
     1. 채팅 메세지 sqlite에서 꺼내서 데이터 모델에 넣기
     - 우선 채팅모델 :  메세지들, 메세지들을 보낸 시각 넣음
     2. 안읽은 메세지 갯수 계산 > 데이터 모델에 넣기
     2-1.메세지들 idx리스트 만들기.
     */
    func get_message_data(chatroom_idx: Int, user_idx: Int){
        
        var statement : OpaquePointer? = nil
        let query = "SELECT * FROM CHAT_CHATTING WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        SockMgr.socket_manager.chat_message_struct.removeAll()
        SockMgr.socket_manager.chat_room_struct.removeAll()
        self.message_idx_list.removeAll()
        
        print("채팅방 입장시 메세지 데이터 가져오기 get_message_data 처리 user_idx: \(user_idx)")
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            //바로 전 메세지를 보낸 시각
            var prev_msg_created : String? = ""
            //바로 전 메세지를 보낸 사람
            var prev_msg_user : String? = ""
            
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            while sqlite3_step(statement) == SQLITE_ROW{
                              
                let chatroom_idx = Int(sqlite3_column_int(statement, 0))
                let chatting_idx = Int(sqlite3_column_int(statement, 1))
                
                self.message_idx_list.append(chatting_idx)
                print("현재 chatting_idx확인: \(chatting_idx)")
                
                let get_user_idx = Int(sqlite3_column_int(statement, 2))
                
                guard let content_query_result = sqlite3_column_text(statement, 3) else {
                    print("채팅방 입장시get_message_data 읽음 처리 위해 닉네임 데이터 가져오는데 nil 임")
                    return
                }
                //채팅 메세지
                let content = String(cString: content_query_result)
                guard let kinds_query_result = sqlite3_column_text(statement, 4) else {
                    print("채팅방 입장시 get_message_data읽음 처리 위해 닉네임 데이터 가져오는데 nil 임")
                    return
                }
                //채팅 메세지
                let kinds = String(cString: kinds_query_result)
                
                guard let created_query_result = sqlite3_column_text(statement, 5) else {
                    print("채팅방 입장시 프론트 데이터 가져오는데 nil 임")
                    return
                }
                let created_at = String(cString: created_query_result)

                var front_created_at : String
                let front_created_query = sqlite3_column_text(statement, 6)
                if let front_created_query =  front_created_query{
                    front_created_at = String(cString: front_created_query)
                }else{
                    front_created_at = ""
                }
                
                var is_my_msg = false
                if user_idx == get_user_idx{
                    is_my_msg = true
                }else{
                    is_my_msg = false
                }
                                
                let is_same =  SockMgr.socket_manager.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(get_user_idx))
                
                var is_last_consecutive_msg : Bool = true
                if is_same{
                    is_last_consecutive_msg = true
                    
                        //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                        SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                    //이 값도 바꿔줘야 맨 첫번째 메세지 ui도 맞게 변경 가능함.
//                    SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].is_same_person_msg = true
                }
                
                SockMgr.socket_manager.chat_message_struct.append(ChatMessage(kinds: kinds, created_at: created_at, sender: String(get_user_idx), message: content, message_idx: chatting_idx,myMsg: is_my_msg, profilePic: "", photo: nil, read_num: 0, front_created_at: front_created_at,is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg ))
               prev_msg_created = created_at
                prev_msg_user = String(get_user_idx)
            }
            print("메세지 저장한 것 확인: \(SockMgr.socket_manager.chat_message_struct)")
            print("메세지 저장한 것 확인: \(socket_manager.chat_message_struct)")
        }else{
            print("채팅방 입장시get_message_data 메세지 데이터 가져오는데 에러 발생: \(errmsg)")
        }
        print("모든 메세지들 idx리스트 만들어졌는지 확인: \(self.message_idx_list)")
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        close_db(statement)
    }
    
    /*
     메세지별 안읽은 갯수 계산
     1.메세지 idx리스트 만들기(a)...채팅방 메세지 가져올 때 만듬.
     2.방 참가자들의 read_last_idx만들기(b)
     3.b<a인 갯수 포문
     4.해당 메세지 idx인 데이터 모델에 안읽은 갯수 넣기
     */
    //방 참여자들의 read_last_idx리스트 만들기
    func get_read_last_list(chatroom_idx: Int) -> Bool{

        self.user_read_list.removeAll()
        var statement : OpaquePointer? = nil
        let query = "SELECT read_last_idx, user_idx FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        
        defer {sqlite3_finalize(statement)}

        guard sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK else{
            
            print("채팅방 입장시 get_read_last_list 메세지 안읽은 갯수 계산 처리 준비 오류 chatroom_idx: \(chatroom_idx)")
            return false
        }
            //sqlite3_bind_int(statement, 0, Int32(chatroom_idx))
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            while sqlite3_step(statement) == SQLITE_ROW{
                print("채팅방 입장시  get_read_last_list 메세지 안읽은 갯수 계산 step들어옴")
                
                //방 참여자들의 read_last_idx리스트
                let read_last_idx = Int(sqlite3_column_int(statement, 0))
                let user_idx = Int(sqlite3_column_int(statement, 1))
                //누가 얼만큼 읽었는지 확인하기 위해 user idx추가
                print("방 참여자들의 read last idx가져오는데 확인: \(read_last_idx), 유저: \(user_idx)")
                self.user_read_list.append(read_last_idx)
            }
        print("모든 메세지들 get_read_last_list 방 참여자들의 read_last_idx 확인: \(self.user_read_list)")
        return true
    }
    
    //채팅방 안에서 모든 메세지들의 안읽은 사람 계산
    func message_unread_num(message_idx: Int)->Int{
        var unread_message_num : [Int] = []
        
        for user_read_num in user_read_list{
            if message_idx > user_read_num{
                unread_message_num.append(message_idx)
                print("넣음, 메세지 idx: \(message_idx), 사용자가 읽은 마지막 idx: \(user_read_num)")
            }else{
                print("안넣음")
            }
        }
        print("최종 결과: \(unread_message_num)")
        return  unread_message_num.count
    }
    
    //최종 마지막 계산
    func calculate_last(){
        print("계산 메소드 들어옴 채팅방의 모든 메세지 idx리스트: \(self.message_idx_list).")
        print("계산 메소드 들어옴 채팅방에서 사용자들이 읽은 마지막 메세지 idx리스트: \(self.user_read_list).")
        
        for message_idx in self.message_idx_list{
            print("계산 메소드 for문 message_idx: \(message_idx)")
            
            self.message_unread_num(message_idx: message_idx)
           
            //집어넣을 데이터의 index찾기
            let insert_idx = SockMgr.socket_manager.chat_message_struct.firstIndex(where: {$0.message_idx == message_idx})
            
            print("채팅방의 마지막 메세지 insert_idx 확인: \(String(describing: insert_idx))")
            SockMgr.socket_manager.chat_message_struct[insert_idx!].read_num = message_unread_num(message_idx: message_idx)
            print("계산 메소드 결과 확인: \( String(describing: SockMgr.socket_manager.chat_message_struct[insert_idx!].read_num))")
        }
    }
    
    //채팅 메세지 보낸 후 서버에서 응답 success받았을 경우 메세지 업데이트
    func update_send_message(chatroom_idx: Int, chatting_idx: Int, front_created_at: String, content: String){

        var statement: OpaquePointer?
        let query = "UPDATE CHAT_CHATTING SET chatting_idx = \(chatting_idx), content = '\(content)' WHERE front_created_at = '\(front_created_at)' AND chatroom_idx= \(chatroom_idx) "
        print("채팅 메세지 업데이트 front : \(front_created_at)")
        print("채팅 메세지 업데이트 chatroom : \(chatroom_idx)")
        
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        print("쿼리문 확인: \(query)")
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("채팅 메세지 업데이트 prepare if문 안에 들어옴")
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("채팅 메세지 데이터 업데이트됨.")
                
            }
            else {
                    print("채팅 메세지 업데이트 안됨.") }
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    
    //채팅 메세지 보낸 후 응답 success일 때 read_last_idx업데이트
    func update_read_after_send(chatroom_idx:Int, read_last_idx: Int){
        
        let query = "UPDATE CHAT_USER SET read_last_idx = ? WHERE chatroom_idx= ? "
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        
        do{
            if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
                print("read last idx 업데이트 위해 받았는지 확인: \(read_last_idx)")
                sqlite3_bind_int(statement, 0, Int32(read_last_idx))
                sqlite3_bind_int(statement, 1, Int32(chatroom_idx))
                print("채팅 메세지 read last idx 업데이트 idx 저장됐는지 확인: \(Int(sqlite3_column_int(statement, 0)))")
                if sqlite3_step(statement) == SQLITE_DONE { print("채팅 메세지 read last idx 업데이트됨.") } else { print("채팅 메세지 read last idx 업데이트 안됨.") }
                
            } else{
                print("채팅 메세지 데이터 집어넣는 오류: \(errormsg)")
            }
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    
    //다른 사람이 메세지를 보냈을 때 채팅방 안에 있을 경우 user read 이벤트 보내기 위해 read_start_idx가져오기.
    func get_read_start_idx(user_idx: Int, chatroom_idx: Int) -> Int{

        let query = "SELECT read_start_idx FROM CHAT_USER WHERE chatroom_idx= ? AND user_idx = ?"
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        let sqliteResult = sqlite3_step(statement)

        var read_start_idx : Int? = nil
        do{
            if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
                
                print("채팅 메세지 보낸 후 read_first_idx 업데이트 prepare if문 안에 들어옴")
                sqlite3_bind_int(statement, 0, Int32(chatroom_idx))
                sqlite3_bind_int(statement, 1, Int32(user_idx))
                read_start_idx = Int(sqlite3_column_int(statement, 1))
                
                if sqliteResult == SQLITE_DONE {
                    print("read_first_idx가져오기 done")
                    sqlite3_reset(statement)
                }else {
                    print("read_first_idx 실패 : \(errormsg)")
                }
                
            } else{
                print("채팅 read_first_idx 가져오는데 오류: \(errormsg)")
            }
        }
        sqlite3_finalize(statement)
        return read_start_idx!
    }
    
    //채팅방 안에 새로운 사람이 들어왔을 경우 유저 정보 넣기 위해
    //채팅방 안의 참여자들 정보 가져오기
    func get_current_chat_user(chatroom_idx: Int){
       
        self.current_chat_user_list.removeAll()
        var statement : OpaquePointer? = nil
        let query = "SELECT user_idx FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("소켓에서 유저 정보 비교 하기 위한 쿼리 chatroom_idx: \(chatroom_idx)")
            //sqlite3_bind_int(statement, 0, Int32(chatroom_idx))
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            while sqlite3_step(statement) == SQLITE_ROW{
                
                let user_idx = Int(sqlite3_column_int(statement, 0))
                print("소켓에서 유저 정보 비교 하기 위한 쿼리: \(user_idx)")
                
                self.current_chat_user_list.append(user_idx)
            }
        }else{
            print("소켓에서 유저 정보 비교 하기 위한 쿼리 에러 발생: \(errmsg)")
        }
        print("소켓에서 유저 정보 리스트 확인: \(self.current_chat_user_list)")
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
    
    //채팅방을 나간 유저 정보 삭제 -> delted at추가하는 것으로 변경함. 1/17
    func delete_exit_user(chatroom_idx: Int, user_idx: Int){

        let deleted_at = self.get_current_time()
        let query = "UPDATE CHAT_USER SET deleted_at = \(deleted_at) WHERE user_idx = ? AND chatroom_idx = ?"
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            print("채팅방 나간 유저 지우는 쿼리: \(user_idx) prepare안")
            
            if sqlite3_step(statement) == SQLITE_DONE{
                
                print("채팅방 나간 유저 지우는 쿼리 완료")
            }else{
                print("채팅방 나간 유저 지우는 쿼리 실패:  \(errormsg)")
            }
            sqlite3_finalize(statement)
        }
    }
    
    //추방 당한 사람이 해당 채팅방 메세지 정보 지우는 것.
    func delete_my_chatroom(chatroom_idx: Int, deleted_at : String, user_idx: Int){

        let query = "UPDATE CHAT_ROOM SET deleted_at = '\(deleted_at)' WHERE idx = \(chatroom_idx)"
        var delete_stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(delete_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &delete_stmt, nil) == SQLITE_OK{
            print("채팅방 메세지 정보 지우는 쿼리: \(chatroom_idx) prepare안")
            
            switch sqlite3_step(delete_stmt) {
            case SQLITE_ROW:
                print("채팅방 메세지 정보 지우는 row")
                break
            case SQLITE_DONE:
                print("채팅방 메세지 정보 지우는 DONE")
                break
            default:
                print("채팅방 메세지 정보 지우는 오류: \(errormsg)")

            }
            sqlite3_finalize(delete_stmt)
        }
    }
    
    //디비 채팅룸 추방 당한 사람이 해당 채팅방 정보 지우는 것.
    func delete_my_chatting(chatroom_idx: Int, user_idx: Int){

        let query = "DELETE FROM CHAT_CHATTING WHERE chatroom_idx = \(chatroom_idx) "
        var delete_stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(delete_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &delete_stmt, nil) == SQLITE_OK{
            print("채팅방 정보 지우는 쿼리: \(chatroom_idx) prepare안")
            
            switch sqlite3_step(delete_stmt) {
            case SQLITE_ROW:
                print("채팅방 정보 지우는 row")

                break
            case SQLITE_DONE:
                print("채팅방 정보 지우는 DONE")
                break
            default:
                print("채팅방 정보 지우는 오류: \(errormsg)")

            }
            sqlite3_finalize(delete_stmt)
            sqlite3_close(delete_stmt)

        }
    }
    
    //추방당한 사람 유저 정보 삭제
    func delete_my_user(chatroom_idx: Int, deleted_at : String, user_idx: Int){
        print("추방당한 사람 유저 정보 삭제 deleted_at :\(deleted_at)")
        let query = "UPDATE CHAT_USER SET deleted_at = '\(deleted_at)' WHERE chatroom_idx = \(chatroom_idx) AND user_idx = \(user_idx)"
        var delete_stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(delete_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &delete_stmt, nil) == SQLITE_OK{
            print("유저 정보 지우는 쿼리: \(chatroom_idx) prepare안")
            
            switch sqlite3_step(delete_stmt) {
            case SQLITE_ROW:
                print("유저 데이터 넣는 row")
                break
            case SQLITE_DONE:
                print("유저 데이터 넣는 DONE")
                break
            default:
                print("유저 데이터 넣는 오류: \(errormsg)")
            }

            sqlite3_finalize(delete_stmt)
            sqlite3_close(delete_stmt)

        }
    }
    
    
    //디비 채팅룸 친구랑 볼래에서 채팅방 주인 이름 가져오기
    func get_creator_nickname(chatroom_idx: Int){
        
        var statement: OpaquePointer? = nil
        //채팅방의 creator_idx와 닉네임을 가져오는데 채팅방의 주인 idx와 채팅유저의 idx가 같은 것.
        let query = "SELECT CHAT_ROOM.creator_idx, CHAT_USER.nickname, CHAT_USER.profile_photo_path FROM CHAT_ROOM INNER JOIN CHAT_USER ON CHAT_ROOM.creator_idx = CHAT_USER.user_idx WHERE CHAT_ROOM.idx = \(chatroom_idx) ORDER BY CHAT_ROOM.idx DESC LIMIT 1"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)

        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            print("주인 이름 가져오는 prepare")
            
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                print("친구랑 볼래 주인 이름 가져오는 데 채팅 룸 idx 확인: \(chatroom_idx)")

                let creator_idx = Int(sqlite3_column_int(statement, 0))
                guard let nickname_result = sqlite3_column_text(statement, 1) else {
                    print("친구랑 볼래 주인 이름 가져오는데 nil 임")
                    return
                }
                //주인 닉네임
                let nickname = String(cString: nickname_result)
                print("친구랑 볼래 주인 이름 확인: \(nickname)")
                
                guard let profile_photo_result = sqlite3_column_text(statement, 2) else {
                    print("친구랑 볼래 주인 이름 가져오는데 nil 임")
                    return
                }
                //주인 사진
                let profile_photo = String(cString: profile_photo_result)
                
                //소켓 클래스에 저장한 뒤 뷰에서 이용.
                SockMgr.socket_manager.creator_nickname = nickname
                SockMgr.socket_manager.creator_idx = creator_idx
                SockMgr.socket_manager.creator_profile_photo = profile_photo
        
        break
        case SQLITE_DONE:
        print("채팅방 주인 이름 가져옴 완료")
        break
            default:
                print("채팅방 정보 지우는 오류: \(errmsg)")
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
    }
    }
    
    //채팅방 드로어에서 추방하기 선택한 유저의 유저 모델 정보 가져오기(내 정보도)
    func get_user_info(chatroom_idx: Int, user_idx: Int){
        let query = "SELECT nickname, profile_photo_path FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx) AND user_idx = \(user_idx)"
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("채팅 유저 정보 가져오는 쿼리 chatroom_idx: \(chatroom_idx)")
            print("채팅 유저 정보 가져오는 쿼리 user_idx: \(user_idx)")
            
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            if sqlite3_step(statement) == SQLITE_ROW{

                guard let query_result_nickname = sqlite3_column_text(statement, 0) else {
                    print("유저 닉네임 데이터 가져오는데 nil 임")
                    return
                }
                let nickname = String(cString: query_result_nickname)
                print("닉네임 확인: \(nickname)")
                guard let query_result_photo = sqlite3_column_text(statement, 1) else {
                    print("유저 프로필 이미지 데이터 가져오는데 nil 임")
                    return
                }
                let profile_photo_path = String(cString: query_result_photo)
                //이곳에 데이터 넣은 후 뷰에서 사용.
                SockMgr.socket_manager.banish_user_info.idx = user_idx
                SockMgr.socket_manager.banish_user_info.nickname = nickname
                SockMgr.socket_manager.banish_user_info.profile_photo_path = profile_photo_path
            }
        }else{
            print("소켓에서 유저 정보 비교 하기 위한 쿼리 에러 발생: \(errormsg)")
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    
    }
    //채팅방 드로어에서 추방하기 선택한 유저의 유저 모델 정보 가져오기(내 정보도)
    func get_my_user_info(chatroom_idx: Int, user_idx: Int){
      
        let query = "SELECT nickname, profile_photo_path FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx) AND user_idx = \(user_idx)"
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("채팅 유저 정보 가져오는 쿼리 chatroom_idx: \(chatroom_idx)")
            print("채팅 유저 정보 가져오는 쿼리 user_idx: \(user_idx)")
            
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            if sqlite3_step(statement) == SQLITE_ROW{

                guard let query_result_nickname = sqlite3_column_text(statement, 0) else {
                    print("유저 닉네임 데이터 가져오는데 nil 임")
                    return
                }
                let nickname = String(cString: query_result_nickname)
                print("닉네임 확인: \(nickname)")
                guard let query_result_photo = sqlite3_column_text(statement, 1) else {
                    print("유저 프로필 이미지 데이터 가져오는데 nil 임")
                    return
                }
                let profile_photo_path = String(cString: query_result_photo)
                SockMgr.socket_manager.my_profile_photo = profile_photo_path
            }
        }else{
            print("소켓에서 유저 정보 비교 하기 위한 쿼리 에러 발생: \(errormsg)")
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    
    }
   
    //일반 채팅방 생성 후 대화에서 이미 대화를 하고 있던 내역이 있을 경우를 체크하기 위함.(1:1채팅)
    //TODO 널값 왔을 때 처리 추가적으로 해야함.
    func check_chat_already(my_idx: Int, friend_idx: Int, nickname: String){

        let query = """
        SELECT CHAT_USER.chatroom_idx
    FROM CHAT_USER LEFT JOIN CHAT_ROOM
    ON CHAT_USER.chatroom_idx = CHAT_ROOM.idx
    WHERE CHAT_USER.chatroom_idx IN(SELECT chatroom_idx FROM CHAT_USER WHERE user_idx IN(\(my_idx), \(friend_idx))
    GROUP BY chatroom_idx HAVING COUNT(chatroom_idx)=2)
    AND CHAT_ROOM.kinds = '일반'
    GROUP BY CHAT_USER.chatroom_idx
    HAVING COUNT(CHAT_USER.chatroom_idx) = 2
"""
        print("쿼리문 확인: \(query)")
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            print("채팅방 정보 존재하는지 가져오는 쿼리 my_idx: \(my_idx)")
            print("채팅방 정보 존재하는지 가져오는 쿼리 friend_idx: \(friend_idx)")
            
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                print("채팅방 정보 존재하는지 가져오는 쿼리  row")
                var chatroom_idx = Int(sqlite3_column_int(statement,0))
                print("채팅방 정보 존재하는지 가져오는 쿼리에서 chatroom_idx: \(chatroom_idx)")
 
                if chatroom_idx
                    == -1{
                    print("-1일떼")
                    //채팅방 정보가 없을 경우 채팅방 idx = -1
                    SockMgr.socket_manager.enter_chatroom_idx = -1
                   
                    //메세지 보내기 이벤트에서 구분값 위해 값 토글
                    SockMgr.socket_manager.is_first_temp_room = true
                }else{
                    print("-1일 아닐 떼")

                    //가져온 채팅방 정보가 있을 경우에는 publish변수에 저장해둠.
                    SockMgr.socket_manager.enter_chatroom_idx = chatroom_idx
                }
                break
            case SQLITE_DONE:
                print("채팅방 정보 존재하는지 가져오는 쿼리에서 SQLITE_DONE: \(sqlite3_step(statement))")
                //채팅방 정보가 없을 경우 채팅방 idx = -1
                SockMgr.socket_manager.enter_chatroom_idx = -1
                //채팅방 메세지 데이터 삭제
                SockMgr.socket_manager.chat_message_struct.removeAll()
                //메세지 보내기 이벤트에서 구분값 위해 값 토글
                SockMgr.socket_manager.is_first_temp_room = true
                print("채팅방 정보 없음 true")
                SockMgr.socket_manager.creator_nickname = nickname
                break
            default:
                print("채팅방 정보 지우는 오류: \(errormsg)")

            }
            sqlite3_finalize(statement)
            sqlite3_close(statement)
        }else{
            print("오류 : \(errormsg)")
        }
    
    }
    
    //유저 정보 가져오기(일대일 채팅에서)
    func get_user_info_private_chat(user_idx: Int){
        
        var statement : OpaquePointer? = nil
        let query = "SELECT nickname, profile_photo_path FROM CHAT_USER WHERE user_idx = \(user_idx)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        let sqliteResult = sqlite3_step(statement)

        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            print("유저 정보 가져오기: \(user_idx)")
            
            //수행 결과에 데이터가 있으면 실행하기 위해 조건 걸은 것.
            if sqlite3_step(statement) == SQLITE_ROW{
                
                guard let query_result_nickname = sqlite3_column_text(statement, 0) else {
                    print("유저 정보 가져오기 닉네임 가져오는데 nil 임")
                    return
                }
                let nickname = String(cString: query_result_nickname)
                print("유저 정보 가져오는데 닉네임 확인: \(nickname)")
                
                guard let query_result_image = sqlite3_column_text(statement, 1) else {
                    print("유저 정보 가져오기 프로필 이미지 가져오는데 nil 임")
                    return
                }
                let profile_photo_path = String(cString: query_result_image)
                
                SockMgr.socket_manager.temp_chat_friend_model = UserChatInListModel(idx: user_idx, nickname: nickname, profile_photo_path: profile_photo_path)
                
                if sqliteResult == SQLITE_DONE {
                    print("유저 정보 가져오기 done")
                }else {
                    print("유저 정보 가져오기 failed : \(sqliteResult)")
                }
            }
            else{
                print("유저 정보 가져오기  에러 발생: \(errmsg)")
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
    }
}
    
    //임시 채팅방에서 메세지 보내기시에 임시로 저장했던 채팅방 찾기
    func update_temp_chatroom(chatroom_idx: Int, creator_idx: Int, before_kinds: String, created_at: String, new_kinds: String){
    
        var find_stmt : OpaquePointer? = nil
        let query = "UPDATE CHAT_ROOM SET idx = \(chatroom_idx), creator_idx = \(creator_idx), kinds = '\(new_kinds)',  created_at = '\(created_at)' WHERE kinds = '\(before_kinds)' "
        let errormsg = String(cString: sqlite3_errmsg(find_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &find_stmt, nil) == SQLITE_OK{
            print("임시 채팅방 업데이트 위해 찾는 쿼리문 Kinds: \(before_kinds)")
            print("임시 채팅방 업데이트 위해 찾는 쿼리문 chatroom_idx: \(chatroom_idx)")

            if sqlite3_step(find_stmt) == SQLITE_DONE{
                
                print("임시 채팅방 업데이트 쿼리 완료")
            }else{
                print("임시 채팅방 업데이트 쿼리 실패:  \(errormsg)")
            }
            sqlite3_finalize(find_stmt)
            sqlite3_close(find_stmt)
        }
    }
    
    //임시 채팅방에서 임시러 저장했던 채팅 테이블 찾기
    func update_temp_chatting(front_created_at: String, chatting_idx: Int, chatroom_idx: Int, content: String, created_at: String, kinds: String){
       
        var find_stmt : OpaquePointer? = nil
        let query = "UPDATE CHAT_CHATTING SET chatroom_idx = \(chatroom_idx), chatting_idx = \(chatting_idx),  content = '\(content)', kinds =  '\(kinds)',  created_at = '\(created_at)' WHERE front_created_at = \(front_created_at) "
        let errormsg = String(cString: sqlite3_errmsg(find_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &find_stmt, nil) == SQLITE_OK{
            print("임시 저장 메세지 업데이트 위해 찾는 쿼리문 front_created_at: \(front_created_at)")

            if sqlite3_step(find_stmt) == SQLITE_DONE{
                
                print("임시 채팅 업데이트 쿼리 완료")
            }else{
                print("임시 채팅 업데이트 쿼리 실패:  \(errormsg)")
            }
            sqlite3_finalize(find_stmt)
            sqlite3_close(find_stmt)
        }
    }
    
    //임시 채팅방에서 임시로 저장했던 유저 테이블 찾기
    func update_temp_user_row(user_idx: Int, chatroom_idx: Int, nickname: String, profile_photo_path: String, read_last_idx: Int, read_start_idx: Int, temp_key: String, server_idx: Int){
    
        var find_stmt : OpaquePointer? = nil
        let query = "UPDATE CHAT_USER SET chatroom_idx = \(chatroom_idx), nickname = '\(nickname)', profile_photo_path = '\(profile_photo_path)', read_last_idx = \(read_last_idx), read_start_idx = \(read_start_idx), server_idx = \(server_idx) WHERE temp_key = '\(temp_key)' AND user_idx = \(user_idx)"
        let errormsg = String(cString: sqlite3_errmsg(find_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &find_stmt, nil) == SQLITE_OK{
            print("임시 저장 유저 정보 업데이트 위해 찾는 쿼리문 temp_key: \(temp_key)")

            if sqlite3_step(find_stmt) == SQLITE_DONE{

                print("임시 유저 정보 업데이트 쿼리 완료")
            }else{
                print("임시 유저 정보 업데이트 쿼리 실패:  \(errormsg)")
            }
            sqlite3_finalize(find_stmt)
            sqlite3_close(find_stmt)
        }
    }
    
    //소켓 연결시 추가된 이벤트 위해서 채팅 메세지중 가장 마지막 메세지 idx가져오기
    func get_last_stored_message_idx() -> Int{
     
        var statement : OpaquePointer? = nil
        let query = "SELECT chatting_idx FROM CHAT_CHATTING ORDER by chatting_idx DESC LIMIT 1 "
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        var last_idx: Int = 0
        
        defer {sqlite3_finalize(statement)}

        guard sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK else{
            print("소켓 연결시 마지막 메세지 idx보내기 위해 가져오는데 오류: \(errmsg)")
            return 0
        }
        switch sqlite3_step(statement) {
        case SQLITE_ROW:
            print("저장된 마지막 메세지 idx가져오기")
            last_idx = Int(sqlite3_column_int(statement, 0))
            print("가져온 채팅 idx 확인: \(last_idx)")
            break
        case SQLITE_DONE:
            print("저장된 마지막 메세지 idx가져오기 done")
           last_idx = 0
            break
        default:
            print("저장된 마지막 메세지 idx가져오기 오류: \(errmsg)")
        }
        return last_idx
    }
    
    //채팅방 드로어에서 카드 정보 보기 클릭시 해당 채팅방의 카드 정보 가져오기 위함.
    func get_card_detail_info(chatroom_idx: Int){
    
        var get_stmt: OpaquePointer? = nil
        let query = "SELECT * FROM CHAT_CARD WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(get_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &get_stmt, nil) == SQLITE_OK {
        switch sqlite3_step(get_stmt) {
        case SQLITE_ROW:
            print("카드 정보 가져오기 sqlite row")
            
            let chatroom_idx = Int(sqlite3_column_int(get_stmt, 0))
            let creator_idx = Int(sqlite3_column_int(get_stmt, 1))
            print("카드 정보 가져오기 creator idx 확인: \(creator_idx)")
            let expiration_at = String(cString:sqlite3_column_text(get_stmt,2))
            let card_photo_path = String(cString:sqlite3_column_text(get_stmt,3))
            let kinds = String(cString:sqlite3_column_text(get_stmt, 4))
            let lock_state = Int(sqlite3_column_int(get_stmt, 5))
            let title = String(cString:sqlite3_column_text(get_stmt, 6))
            let introduce = String(cString:sqlite3_column_text(get_stmt, 7))
            let address = String(cString:sqlite3_column_text(get_stmt, 8))
            let cur_user = Int(sqlite3_column_int(get_stmt, 9))
            let apply_user = Int(sqlite3_column_int(get_stmt, 10))

            let map_lat = String(cString:sqlite3_column_text(get_stmt, 11))
            let map_lng = String(cString:sqlite3_column_text(get_stmt, 12))
            let created_at = String(cString:sqlite3_column_text(get_stmt, 13))
            let updated_at = String(cString:sqlite3_column_text(get_stmt, 14))
            let deleted_at = String(cString:sqlite3_column_text(get_stmt, 15))
            
            let year = expiration_at.split(separator: "-")[0]
            let month = expiration_at.split(separator: "-")[1]
            let date_and_time = expiration_at.split(separator: "-")[2]
            print("카드 정보 가져올 때 date and time: \(date_and_time)")
            
            let promise_day = year+"-"+month+"-"+date_and_time
            print("카드 정보 가져오기 promise_day 확인: \(promise_day)")
            
            SockMgr.socket_manager.card_struct.creator_idx = creator_idx
            SockMgr.socket_manager.card_struct.kinds = kinds
            SockMgr.socket_manager.card_struct.card_photo_path = card_photo_path
            SockMgr.socket_manager.card_struct.lock_state = lock_state
            SockMgr.socket_manager.card_struct.title = title
            SockMgr.socket_manager.card_struct.introduce = introduce
            SockMgr.socket_manager.card_struct.address = address

            SockMgr.socket_manager.card_struct.map_lat = map_lat
            SockMgr.socket_manager.card_struct.map_lng = map_lng
            SockMgr.socket_manager.card_struct.cur_user = cur_user
            SockMgr.socket_manager.card_struct.apply_user = apply_user
            SockMgr.socket_manager.card_struct.expiration_at = promise_day
            SockMgr.socket_manager.card_struct.created_at = created_at
            SockMgr.socket_manager.card_struct.updated_at = updated_at
            SockMgr.socket_manager.card_struct.deleted_at = deleted_at
            print("카드 정보 넣은 것 확인: \(SockMgr.socket_manager.card_struct)")
            break
        case SQLITE_DONE:
            print("카드 정보 가져오기 sqlite done")
            print("카드 데이터 넣은 것 확인: \(SockMgr.socket_manager.card_struct)")
            break
        default:
            print("카드 정보 가져오기 오류: \(errmsg)")
        }
        }
        sqlite3_finalize(get_stmt)
    }
    
    func get_tag_info(chatroom_idx: Int){
        
        var get_stmt: OpaquePointer? = nil
        let query = "SELECT * FROM CHAT_TAG WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(get_stmt)!)
        let sqlite_result = sqlite3_step(get_stmt)
        
        if sqlite3_prepare_v2(self.db, query, -1, &get_stmt, nil) == SQLITE_OK{
        
        while sqlite_result == SQLITE_ROW {
            
            print("태그 정보 가져오기 sqlite row")
            
            let chatroom_idx = Int(sqlite3_column_int(get_stmt, 0))
            let tag_idx = Int(sqlite3_column_int(get_stmt, 1))
            print("태그 정보 가져오기 확인: \(tag_idx)")
            let tag_name = String(cString:sqlite3_column_text(get_stmt, 2))
            SockMgr.socket_manager.tag_struct.append(TagModel(idx: tag_idx, tag_name: tag_name))
        }
        if sqlite_result ==  SQLITE_DONE{
            print("태그 정보 가져오기 sqlite done")
            print("태그 데이터 넣은 것 확인: \(SockMgr.socket_manager.tag_struct)")
        }
        else{
            print("태그 정보 가져오기 오류: \(errmsg)")
        }
    }
        print("태그 데이터 넣은 것 확인: \(SockMgr.socket_manager.tag_struct)")
        sqlite3_finalize(get_stmt)
    }
    
    //메인에서 카드 편집한 후에 채팅 서버에 데이터 보낼 때 chatroom_idx보내기 위함.
    func get_chatroom_from_card(card_idx: Int) -> Int{
        open_db()
        var get_stmt: OpaquePointer? = nil
        let query = "SELECT idx FROM CHAT_ROOM WHERE card_idx = \(card_idx)"
        let errormsg = String(cString: sqlite3_errmsg(get_stmt)!)
        var chatroom_idx: Int = -1
        
        if sqlite3_prepare_v2(self.db, query, -1, &get_stmt, nil) == SQLITE_OK{
            print("받은 카드 idx: \(card_idx)")
            
            switch sqlite3_step(get_stmt) {
            case SQLITE_ROW:
                print("카드 idx이용해 채팅방 idx가져오기 row")
                chatroom_idx = Int(sqlite3_column_int(get_stmt, 0))
                print("카드 idx이용해 가져온 채팅방 번호: \(chatroom_idx)")
                break
            case SQLITE_DONE:
                print("카드 idx이용해 채팅방 idx가져오기 DONE")
                break
            default:
                print("카드 idx이용해 채팅방 idx가져오기 에러: \(errormsg)")
            }
        }
        sqlite3_finalize(get_stmt)
        return chatroom_idx
    }
    
    //메인에서 카드 수정시 채팅 서버에 보낼 카드 모델 데이터 만들기 위함
    func get_card_info_from_main(chatroom_idx: Int){
        var get_stmt: OpaquePointer? = nil
        let query = "SELECT * FROM CHAT_CARD WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(get_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &get_stmt, nil) == SQLITE_OK {
        switch sqlite3_step(get_stmt) {
        case SQLITE_ROW:
            print("카드 정보 가져오기 sqlite row")
   
            let chatroom_idx = Int(sqlite3_column_int(get_stmt, 0))
            let creator_idx = Int(sqlite3_column_int(get_stmt, 1))
            print("카드 정보 가져오기 creator idx 확인: \(creator_idx)")
            let expiration_at = String(cString:sqlite3_column_text(get_stmt,2))
            let card_photo_path = String(cString:sqlite3_column_text(get_stmt,3))
            let kinds = String(cString:sqlite3_column_text(get_stmt, 4))
            let lock_state = Int(sqlite3_column_int(get_stmt, 5))
            let title = String(cString:sqlite3_column_text(get_stmt, 6))
            let introduce = String(cString:sqlite3_column_text(get_stmt, 7))
            let address = String(cString:sqlite3_column_text(get_stmt, 8))
            let cur_user = Int(sqlite3_column_int(get_stmt, 9))
            let apply_user = Int(sqlite3_column_int(get_stmt, 10))

            let map_lat = String(cString:sqlite3_column_text(get_stmt, 11))
            let map_lng = String(cString:sqlite3_column_text(get_stmt, 12))
            let created_at = String(cString:sqlite3_column_text(get_stmt, 13))
            let updated_at = String(cString:sqlite3_column_text(get_stmt, 14))
            let deleted_at = String(cString:sqlite3_column_text(get_stmt, 15))
            
            var promise_day : String = ""
            if expiration_at != ""{
            let year = expiration_at.split(separator: "-")[0]
            let month = expiration_at.split(separator: "-")[1]
            let date_and_time = expiration_at.split(separator: "-")[2]
            let date = date_and_time.split(separator: " ")[0]
            let time = date_and_time.split(separator: " ")[1]
            promise_day = year+"년"+month+"월 "+date+"일"
            print("카드 정보 가져오기 promise_day 확인: \(promise_day)")
            }
            
            socket_manager.card_struct.creator_idx = creator_idx
            socket_manager.card_struct.kinds = kinds
            socket_manager.card_struct.card_photo_path = card_photo_path
            socket_manager.card_struct.lock_state = lock_state
            socket_manager.card_struct.title = title
            socket_manager.card_struct.introduce = introduce
            socket_manager.card_struct.address = address

            socket_manager.card_struct.map_lat = map_lat
            socket_manager.card_struct.map_lng = map_lng
            socket_manager.card_struct.cur_user = cur_user
            socket_manager.card_struct.apply_user = apply_user
            socket_manager.card_struct.expiration_at = promise_day
            socket_manager.card_struct.created_at = created_at
            socket_manager.card_struct.updated_at = updated_at
            socket_manager.card_struct.deleted_at = deleted_at
            print("디비에서 카드 정보 넣은 것 확인: \(socket_manager.card_struct)")
            break
        case SQLITE_DONE:
            print("카드 정보 가져오기 sqlite done")
            print("카드 데이터 넣은 것 확인: \(SockMgr.socket_manager.card_struct)")
            break
        default:
            print("카드 정보 가져오기 오류: \(errmsg)")
        }
        }
        sqlite3_finalize(get_stmt)
    }

    //채팅 메세지 데이터 끄고 보냈을 때 -1이었던 채팅 메세지 idx를 -2로 바꾸기
    func change_message_status(){
        open_db()
        var stmt: OpaquePointer? = nil
        let query = "UPDATE CHAT_CHATTING SET chatting_idx = -2 WHERE chatting_idx = -1"
        let errormsg = String(cString: sqlite3_errmsg(stmt)!)
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
            
            print("채팅 메세지 -2로 업데이트 prepare if문 안에 들어옴")
            
            if sqlite3_step(stmt) == SQLITE_DONE { print("채팅 메세지 -2로 데이터 업데이트됨.") } else { print("채팅 메세지 -2로 업데이트 안됨.") }
            sqlite3_reset(stmt)
        }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
    }
    
    //카드 idx를 가지고 카드 상세 정보들 가져올 때 사용.
    func get_card_by_card_idx(card_idx: Int){
        
        var get_stmt: OpaquePointer? = nil
        let query = "SELECT * FROM CHAT_CARD INNER JOIN CHAT_ROOM ON CHAT_CARD.chatroom_idx = CHAT_ROOM.idx WHERE CHAT_ROOM.card_idx = \(card_idx)"
        let errormsg = String(cString: sqlite3_errmsg(get_stmt)!)

        if sqlite3_prepare_v2(self.db, query, -1, &get_stmt, nil) == SQLITE_OK{
            print("카드 idx로 카드 상세 정보 가져오기 : \(card_idx)")
            switch sqlite3_step(get_stmt) {
            case SQLITE_ROW:
                print("카드 정보 가져오기 sqlite row")
       
                let chatroom_idx = Int(sqlite3_column_int(get_stmt, 0))
                let creator_idx = Int(sqlite3_column_int(get_stmt, 1))
                print("카드 정보 가져오기 creator idx 확인: \(creator_idx)")
                let expiration_at = String(cString:sqlite3_column_text(get_stmt,2))
                let card_photo_path = String(cString:sqlite3_column_text(get_stmt,3))
                let kinds = String(cString:sqlite3_column_text(get_stmt, 4))
                let lock_state = Int(sqlite3_column_int(get_stmt, 5))
                let title = String(cString:sqlite3_column_text(get_stmt, 6))
                let introduce = String(cString:sqlite3_column_text(get_stmt, 7))
                let address = String(cString:sqlite3_column_text(get_stmt, 8))

                let cur_user = Int(sqlite3_column_int(get_stmt, 9))
                let apply_user = Int(sqlite3_column_int(get_stmt, 10))

                let map_lat = String(cString:sqlite3_column_text(get_stmt, 11))
                let map_lng = String(cString:sqlite3_column_text(get_stmt, 12))
                let created_at = String(cString:sqlite3_column_text(get_stmt, 13))
                let updated_at = String(cString:sqlite3_column_text(get_stmt, 14))
                let deleted_at = String(cString:sqlite3_column_text(get_stmt, 15))
                
                let year = expiration_at.split(separator: "-")[0]
                let month = expiration_at.split(separator: "-")[1]
                let date_and_time = expiration_at.split(separator: "-")[2]
                let date = date_and_time.split(separator: " ")[0]
                let time = date_and_time.split(separator: " ")[1]
                let promise_day = year+"년"+month+"월 "+date+"일"
                print("카드 정보 가져오기 promise_day 확인: \(promise_day)")
                
                //내 카드에 초대하기 -> 채팅룸 idx를 알 방법이 없어 카드 1개 클릭했을 때 invite_chatroom_idx에 넣음.
                SockMgr.socket_manager.card_struct.creator_idx = creator_idx
                SockMgr.socket_manager.card_struct.kinds = kinds
                SockMgr.socket_manager.card_struct.card_photo_path = card_photo_path
                SockMgr.socket_manager.card_struct.lock_state = lock_state
                SockMgr.socket_manager.card_struct.title = title
                SockMgr.socket_manager.card_struct.introduce = introduce
                SockMgr.socket_manager.card_struct.address = address

                SockMgr.socket_manager.card_struct.map_lat = map_lat
                SockMgr.socket_manager.card_struct.map_lng = map_lng
                SockMgr.socket_manager.card_struct.cur_user = cur_user
                SockMgr.socket_manager.card_struct.apply_user = apply_user
                SockMgr.socket_manager.card_struct.expiration_at = promise_day
                SockMgr.socket_manager.card_struct.created_at = created_at
                SockMgr.socket_manager.card_struct.updated_at = updated_at
                SockMgr.socket_manager.card_struct.deleted_at = deleted_at
                print("카드 정보 넣은 것 확인: \(SockMgr.socket_manager.card_struct)")
                
                SockMgr.socket_manager.invite_chatroom_idx = chatroom_idx
                print("채팅방 idx 저장 확인: \( SockMgr.socket_manager.invite_chatroom_idx)")
                break
            case SQLITE_DONE:
                print("카드 정보 가져오기 sqlite done")
                print("카드 데이터 넣은 것 확인: \(SockMgr.socket_manager.card_struct)")
                break
            default:
                print("카드 정보 가져오기 오류: \(errormsg)")
            }
            }
            sqlite3_finalize(get_stmt)
    }
    //채팅방 설정 - 채팅방 이름 변경시 쿼리
    func update_room_name(chatroom_idx: Int, room_name: String){
   
        let query = "UPDATE CHAT_ROOM SET room_name = '\(room_name)' WHERE idx = \(chatroom_idx)"
        var stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(stmt)!)
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
            print("채팅방 이름 업데이트 쿼리문 채팅방 idx: \(chatroom_idx), 채팅방 이름: \(room_name)")
            
            if sqlite3_step(stmt) == SQLITE_DONE{
                //방 이름을 변경하는 것은 채팅방 설정에서만 가능.
                //바꾼 것이 success하면 채팅방에서 room_name 보여지는 것도 데이터 넣어줌.
                SockMgr.socket_manager.current_chatroom_info_struct.room_name = room_name
                //채팅방 목록에서 사용하는 모델에도 업데이트
                var model_idx : Int
                print("어떤 종류 채팅방 바꿨는지 모델 먼저 확인: \(SockMgr.socket_manager.friend_chat_model)")
                print("어떤 종류 채팅방 바꿨는지 모델 먼저 확인: \(socket_manager.friend_chat_model)")
                //1.친구 탭 채팅방인지 찾기
                model_idx = SockMgr.socket_manager.friend_chat_model.firstIndex(where: {
                    $0.chatroom_idx == chatroom_idx
                }) ?? -1
                
                if model_idx != -1{
                    SockMgr.socket_manager.friend_chat_model[model_idx].room_name = room_name
                    print("친구 카드 채팅방 이름 바꿈.\(SockMgr.socket_manager.friend_chat_model[model_idx])")
                }else{
                    model_idx = SockMgr.socket_manager.group_chat_model.firstIndex(where: {
                        $0.chatroom_idx == chatroom_idx
                    }) ?? -1
                    
                    if model_idx != -1{
                        
                        SockMgr.socket_manager.group_chat_model[model_idx].room_name = room_name
                        print("모임 카드 채팅방 이름 바꿈.\(SockMgr.socket_manager.group_chat_model[model_idx])")
                        
                    }else{
                        
                        model_idx = SockMgr.socket_manager.normal_chat_model.firstIndex(where: {
                            $0.chatroom_idx == chatroom_idx
                        }) ?? -1
                        
                        if model_idx != -1{
                            SockMgr.socket_manager.normal_chat_model[model_idx].room_name = room_name
                            print("일반 채팅방 이름 바꿈.\(SockMgr.socket_manager.normal_chat_model[model_idx])")
                        }
                    }
                }
                
                
                print("채팅방 이름 업데이트 쿼리 완료")
            }else{
                print("채팅방 이름 업데이트 쿼리 실패:  \(errormsg)")
            }
            sqlite3_finalize(stmt)
            sqlite3_close(stmt)
        }
    }
    //서버에 이벤트 보낼 때 서버 idx보내기 위해 특정 채팅방의 server idx가져오는 것.
    func get_server_idx_to_chat_server(user_idx: Int, chatroom_idx: Int){
        let query = "SELECT server_idx FROM CHAT_USER WHERE user_idx= \(user_idx) AND chatroom_idx = \(chatroom_idx)"
        print("쿼리문 확인: \(query)")
        var stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
            print("채팅 유저 server idx 쿼리문 ")
            
            switch sqlite3_step(stmt) {
                case SQLITE_ROW:
                    print("카드 idx이용해 채팅방 idx가져오기 row")
                self.user_server_idx = Int(sqlite3_column_int(stmt, 0))
            self.exist_chatroom_list.append(user_server_idx)
                    print("카드 idx이용해 가져온 채팅방 번호: \(chatroom_idx)")
                    print("채팅 유저 server idx 쿼리문 완료: \(self.exist_chatroom_list)")

                    break
                case SQLITE_DONE:
            print("채팅 유저 server idx 쿼리문 완료: \(self.exist_chatroom_list)")
            
            break
                default:
                    print("카드 idx이용해 채팅방 idx가져오기 에러: \(errormsg)")
                }
        }else{
            print("채팅 유저 server idx쿼리 프리페어 오류")
        }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
        close_db(stmt)
    }

    //서버 idx 가져오기
    func get_client_server_idx_user(){

        let query = "SELECT server_idx FROM CHAT_USER"
        self.exist_chatroom_list.removeAll()
        var stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
            print("채팅 1명 유저 server idx 가져오는 쿼리문 ")
            
            while sqlite3_step(stmt) == SQLITE_ROW{
                    print("채팅 1명 유저 server idx 가져오는 쿼리문 row")
                    self.user_server_idx = Int(sqlite3_column_int(stmt, 0))
                    self.exist_chatroom_list.append(user_server_idx)
                    print("채팅 유저 server idx 쿼리문 완료: \(self.exist_chatroom_list)")
       
                }
        }else{
            print("채팅 유저 server idx쿼리 프리페어 오류")
        }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
    }
    
    //chat user, chatroom, card테이블의 deleted at 업데이트
    func update_exit_user_table(chatroom_idx: Int){

        var statement : OpaquePointer? = nil
        let query = "UPDATE CHAT_USER SET deleted_at = CURRENT_TIMESTAMP WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        print("업데이트하려는 채팅유저 테이블 chatroom idx: \(chatroom_idx)")
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            switch sqlite3_step(statement) {
                case SQLITE_ROW:
              print("채팅유저 테이블 update deleted at row")
                    break
            case SQLITE_DONE:
                print("채팅유저 테이블 update deleted at 업데이트됨.")
            break
                default:
            print("채팅유저 테이블 update deleted at 에러 발생: \(errmsg)")
                    
        }
        }
        sqlite3_finalize(statement)
    }
    
    func update_exit_user_chatroom(chatroom_idx: Int){
        var statement : OpaquePointer? = nil
        let query = "UPDATE CHAT_ROOM SET deleted_at = CURRENT_TIMESTAMP, state = 1 WHERE idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        print("업데이트하려는 chatroom 테이블 chatroom idx: \(chatroom_idx)")
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            switch sqlite3_step(statement) {
                case SQLITE_ROW:
              print("chatroom 테이블 update deleted at row")
                    break
            case SQLITE_DONE:
                print("chatroom 테이블 update deleted at 업데이트됨.")
            break
                default:
            print("chatroom 테이블 update deleted at 에러 발생: \(errmsg)")
        }
        }
        sqlite3_finalize(statement)
    }
    
    //카드 테이블
    func update_exit_user_card(chatroom_idx: Int){
        var statement : OpaquePointer? = nil
        let query = "UPDATE CHAT_CARD SET deleted_at = CURRENT_TIMESTAMP WHERE chatroom_idx = \(chatroom_idx)"
        let errmsg = String(cString: sqlite3_errmsg(statement)!)
        print("업데이트하려는 card 테이블 chatroom idx: \(chatroom_idx)")
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            
            switch sqlite3_step(statement) {
                case SQLITE_ROW:
              print("card 테이블 update deleted at row")
                    break
            case SQLITE_DONE:
                print("card 테이블 update deleted at 업데이트됨.")
            break
                default:
            print("card 테이블 update deleted at 에러 발생: \(errmsg)")
        }
        }
        sqlite3_finalize(statement)
    }
    
    //채팅방별 총 인원수 가져오기
    func get_members_in_chatroom(chatroom_idx: Int, kinds: String){
        let query = "SELECT COUNT(user_idx) FROM CHAT_USER WHERE chatroom_idx = \(chatroom_idx)"
        print("쿼리문 확인: \(query)")
        var stmt: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK{
            
            switch sqlite3_step(stmt) {
                case SQLITE_ROW:
                    print("채팅방별 총 인원수 가져오기 row")
                let user_num = Int(sqlite3_column_int(stmt, 0))
                    print("채팅방별 총 인원수 가져오기: \(user_num)")
                    
                    if kinds == "친구"{
                        let model_idx = SockMgr.socket_manager.friend_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        SockMgr.socket_manager.friend_chat_model[model_idx!].total_member_num = user_num
                        print("친구랑 볼래 데이터 넣은 것 확인: \(SockMgr.socket_manager.friend_chat_model)")
                        
                       
                    }else if kinds == "모임"{
                        let model_idx = SockMgr.socket_manager.group_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        SockMgr.socket_manager.group_chat_model[model_idx!].total_member_num = user_num
                        
                    }else{
                        let model_idx = SockMgr.socket_manager.normal_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        SockMgr.socket_manager.normal_chat_model[model_idx!].total_member_num = user_num
                    }
                    break
                case SQLITE_DONE:
            print("채팅방별 총 인원수 가져오기 쿼리문 완료: ")
            
            break
                default:
                    print("채팅방별 총 인원수 가져오기 에러: \(errormsg)")
                }
        }else{
            print("채팅방별 총 인원수 가져오기 프리페어 오류")
        }
        sqlite3_finalize(stmt)
        sqlite3_close(stmt)
        close_db(stmt)
    }
    
    //디비에 저장된 내가 만든 모든 카드 가져오기.
    func get_all_cards(user_idx: Int){
        var get_stmt: OpaquePointer? = nil
        let query =
            """
        SELECT * FROM CHAT_CARD
            INNER JOIN CHAT_ROOM
             ON CHAT_CARD.chatroom_idx = CHAT_ROOM.idx
            WHERE CHAT_CARD.creator_idx = \(user_idx) AND (CHAT_CARD.deleted_at = '' OR CHAT_CARD.deleted_at IS NULL)
    """
        let errmsg = String(cString: sqlite3_errmsg(get_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &get_stmt, nil) == SQLITE_OK {
            
            while sqlite3_step(get_stmt) == SQLITE_ROW{
            print("카드 정보 가져오기 sqlite row")
   
            let chatroom_idx = Int(sqlite3_column_int(get_stmt, 0))
            let creator_idx = Int(sqlite3_column_int(get_stmt, 1))
            print("카드 정보 가져오기 creator idx 확인: \(creator_idx)")
            let expiration_at = String(cString:sqlite3_column_text(get_stmt,2))
            let card_photo_path = String(cString:sqlite3_column_text(get_stmt,3))
            let kinds = String(cString:sqlite3_column_text(get_stmt, 4))
            let lock_state = Int(sqlite3_column_int(get_stmt, 5))
            let title = String(cString:sqlite3_column_text(get_stmt, 6))
            let introduce = String(cString:sqlite3_column_text(get_stmt, 7))
            let address = String(cString:sqlite3_column_text(get_stmt, 8))
            let cur_user = Int(sqlite3_column_int(get_stmt, 9))
            let apply_user = Int(sqlite3_column_int(get_stmt, 10))

            let map_lat = String(cString:sqlite3_column_text(get_stmt, 11))
            let map_lng = String(cString:sqlite3_column_text(get_stmt, 12))
            let created_at = String(cString:sqlite3_column_text(get_stmt, 13))
            let updated_at = String(cString:sqlite3_column_text(get_stmt, 14))
            let deleted_at = String(cString:sqlite3_column_text(get_stmt, 15))
            let idx_from_chatroom = Int(sqlite3_column_int(get_stmt, 16))
            let card_idx = Int(sqlite3_column_int(get_stmt, 17))
            let room_name = String(cString:sqlite3_column_text(get_stmt, 20))
          
                 
            let year = expiration_at.split(separator: "-")[0]
            let month = expiration_at.split(separator: "-")[1]
            let date_and_time = expiration_at.split(separator: "-")[2]
            let date = date_and_time.split(separator: " ")[0]
            let time = date_and_time.split(separator: " ")[1]
            let promise_day = year+"년"+month+"월 "+date+"일"
            print("카드 정보 가져오기 promise_day 확인: \(promise_day)")
                
                if kinds == "친구"{
                    //TODO 내 프로필 사진 user defaults에 저장한 후 꺼내는 것 작성하기. 일단 널로 저장함.
                    SockMgr.socket_manager.friend_card.append(FriendVollehCardStruct(card_idx: card_idx, kinds: kinds, expiration_at: expiration_at, tags: [], creator: Creator(idx: user_idx, nickname: ChatDataManager.shared.my_nickname!, profile_photo_path:  ""), offset: 0.0))
                    
                }else if kinds == "모임"{
                    //server idx는 유저 테이블에 있는데 여기서는 임의로 -1넣음.
                    SockMgr.socket_manager.group_card.append(GroupCardStruct( card_idx: card_idx, title: title, kinds: "모임", expiration_at: expiration_at, address: address, map_lat: map_lat, map_lng: map_lng, cur_user: cur_user, apply_user: apply_user, introduce: introduce, tags: [], creator: Creator(idx: user_idx, nickname: ChatDataManager.shared.my_nickname!, profile_photo_path:  ""), offset: 0.0, chatroom_idx: String(chatroom_idx), server_idx: -1))
                }
 
            }
            print("디비에서 내가 만든 카드 정보 넣은 것 확인: \(SockMgr.socket_manager.friend_card), 모임: \(SockMgr.socket_manager.group_card)")
        }else{
            print("내가 만든 모든 카드 가져오기 에러: \(errmsg)")
        }
        sqlite3_finalize(get_stmt)
        sqlite3_close(get_stmt)
    }
    
    func get_all_tag_info(user_idx: Int){
        var get_stmt: OpaquePointer? = nil
        let query = """
        SELECT CHAT_TAG.tag_idx, CHAT_TAG.tag_name, CHAT_TAG.chatroom_idx, CHAT_ROOM.card_idx, CHAT_ROOM.kinds FROM CHAT_TAG
        INNER JOIN CHAT_ROOM
     ON CHAT_TAG.chatroom_idx = CHAT_ROOM.idx
    WHERE CHAT_ROOM.creator_idx = \(user_idx)
"""
        print("쿼리문 확인: \(query)")
        let errmsg = String(cString: sqlite3_errmsg(get_stmt)!)
        
        if sqlite3_prepare_v2(self.db, query, -1, &get_stmt, nil) == SQLITE_OK{
            
        while sqlite3_step(get_stmt) == SQLITE_ROW {
            
            print("태그 정보 가져오기 sqlite row")
            let tag_idx = Int(sqlite3_column_int(get_stmt, 0))
            print("태그 정보 가져오기 확인: \(tag_idx)")
            let tag_name = String(cString:sqlite3_column_text(get_stmt, 1))
            let chatroom_idx = Int(sqlite3_column_int(get_stmt, 2))
            let card_idx = Int(sqlite3_column_int(get_stmt, 3))
            let kinds = String(cString:sqlite3_column_text(get_stmt, 4))
            print("태그 카드 종류: \(kinds)")
            
            if kinds == "친구"{
                
                var stored_idx : Int? = -1
                 stored_idx = SockMgr.socket_manager.friend_card.firstIndex(where: {
                    $0.card_idx == card_idx
                }) ?? -1
                if stored_idx != -1{
                    print("해당 모델: \(SockMgr.socket_manager.friend_card[stored_idx!])")
                    SockMgr.socket_manager.friend_card[stored_idx!].tags?.append(FriendVollehTags(idx: tag_idx, tag_name: tag_name))
           
                }
            //모임 카드의 태그인 경우
            }else{
                var stored_idx : Int? = -1
                 stored_idx = SockMgr.socket_manager.group_card.firstIndex(where: {
                    $0.card_idx == card_idx
                }) ?? -1
                if stored_idx != -1{
                    print("해당 모델: \(SockMgr.socket_manager.group_card[stored_idx!])")
                    SockMgr.socket_manager.group_card[stored_idx!].tags?.append(Tags(idx: tag_idx, tag_name: tag_name))
                }
            }
        }
    }else{
        print("태그 가져오는데 에러: \(errmsg)")
    }
        print("그룹 카드태그 데이터 넣은 것 확인: \(SockMgr.socket_manager.group_card)")
        sqlite3_finalize(get_stmt)
    }
   

    //특정 채팅 메세지 삭제하기
    func delete_chat_msg(front_created_at: String){
        
        let query = "DELETE FROM CHAT_CHATTING WHERE front_created_at = '\(front_created_at)'"
        var statement: OpaquePointer? = nil
        let errormsg = String(cString: sqlite3_errmsg(statement)!)
        print("쿼리문 확인: \(query)")
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            print("특정 채팅 메세지 삭제하기 메소드 prepare안")
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
            print("특정 채팅 메세지 삭제하기sqlite row")
                break
            case SQLITE_DONE:
                print("특정 채팅 메세지 삭제하기 완료")
                break
            default:
                print("특정 채팅 메세지 삭제하기 에러: \(errormsg)")
            }
        }
        sqlite3_finalize(statement)
    }
}
    

private extension Calendar{
    
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
            let fromDate = startOfDay(for: from)
            let toDate = startOfDay(for: to)
            let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
            
            return numberOfDays.day! + 1 // <1>
        }
}




