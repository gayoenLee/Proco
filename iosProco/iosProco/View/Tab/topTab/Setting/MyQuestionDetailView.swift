//
//  MyQuestionDetailView.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
//

import SwiftUI


struct AlertItem: Identifiable {
    var id = UUID()
    var title: Text
    var message: Text?
    var dismissButton: Alert.Button?
}

struct MyQuestionDetailView: View {
    @Environment(\.presentationMode) var presentation

    var question_model : MyQuestionModel
    @Environment(\.editMode) var editMode
    @ObservedObject var main_vm: SettingViewModel
    @State var ask_content: String = ""
    @State private var edit_content: String = ""
    //수정, 삭제 메뉴 있는 버튼
    @State private var show_menus : Bool = false
    //삭제 한 번 더 묻는 알림창
    @State private var show_ask_delete : Bool = false
    
    @State private var alert_item : AlertItem?
    
    var body: some View {
        VStack{
            
            HStack{
                Spacer()
            }
            my_question_date
            my_question_content
            
            HStack{
                Text("답변")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
                if question_model.process_content == ""{
                    Text("답변대기중")
                        .padding(UIScreen.main.bounds.width/25)
                        .font(.custom(Font.t_extra_bold, size: 15))
                        .foregroundColor(.proco_white)
                        .background(Color.gray)
                        .cornerRadius(25)
                        .padding([.trailing], UIScreen.main.bounds.width/25)
                }
            }
            //답변대기인 경우
            if question_model.process_content == ""{
                Spacer()
                //답변완료인 경우
            }else{
                answer_date
                answer_content
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("문의 내역")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading, content: {
                if (.active == self.editMode?.wrappedValue){
                    Button(action: {
                        print("취소 클릭")
                        self.editMode?.wrappedValue = .inactive
                    }){
                        Text("취소")
                            .font(.custom(Font.n_extra_bold, size: 16))
                            .foregroundColor(Color.proco_white)
                            .background(Color.proco_blue)
                            .cornerRadius(5)
                    }
                }else{
                    //leading에 값이 있어야 뒤에 toolbar item과 백버튼이 같이 보임.
                    Text("")
                }
            })
            ToolbarItem(placement: .navigationBarTrailing){
                            
                            if (.active == self.editMode?.wrappedValue){
                                
                                Button(action: {
                                    print("편집 완료 버튼 클릭")
                                    let question_idx = question_model.idx
                                    let content = edit_content
                                    ask_content = edit_content
                                    
                                    //편집 통신
                                    self.main_vm.edit_question(question_idx: question_idx, content: content)
                                    
                                    self.editMode?.wrappedValue = .inactive
                                    
                                }){
                                    Text("완료")
                                        .font(.custom(Font.n_extra_bold, size: 16))
                                        .foregroundColor(Color.proco_white)
                                        .background(Color.proco_blue)
                                        .cornerRadius(5)
                                }
                            }
                            //답변대기시에만 수정, 삭제가 가능하다.
                            if question_model.process_content == ""{
                                
                                Button(action: {
                                    print("컨텍스트 메뉴 클릭")
                                    self.show_menus = true
                                    
                                }){
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(Color.proco_black)
                                }
                            }
                        }
        })
        .actionSheet(isPresented: self.$show_menus, content: {
            ActionSheet(title: Text("내 문의내역"), message: nil, buttons: [.default(Text("수정하기"), action: {
                
                print("편집버튼 클릭")
                self.edit_content = self.ask_content
                self.editMode?.wrappedValue = .active
                
            }), .default(Text("삭제하기"), action: {
                
                print("삭제 버튼 클릭")
                self.show_ask_delete
                    = true
                
            }), .cancel(Text("취소"))])
            
        })
        .alert(isPresented: self.$show_ask_delete, content: {
            Alert(title: Text("알림"), message: Text("문의를 삭제하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                
                //삭제 통신
                self.main_vm.delete_question(question_idx: question_model.idx)
                
            }), secondaryButton: Alert.Button.cancel(Text("취소")))
        })
        //키보드 올라왓을 때 화면 다른 곳 터치하면 키보드 내려가는 것
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear{
            self.ask_content = question_model.content
        }
    }
}

private extension MyQuestionDetailView{
        
    var my_question_date : some View{
        
        HStack{
            Text("문의 날짜")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(Color.proco_black)
            
            Spacer()
            Text(question_model.created_at!.split(separator: " ")[0])
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
        }
    }
    
    var my_question_content : some View{
            
            VStack{
                HStack{
                    Text("문의 내용")
                        .font(.custom(Font.t_extra_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                    Spacer()
                }
                if  (.active == self.editMode?.wrappedValue){
                    
                    TextEditor(text: $edit_content)
                        .font(.custom(Font.n_bold, size: 14))
                        .foregroundColor(Color.proco_black)
                        .colorMultiply(Color.light_gray)
                        .cornerRadius(3)
                        .background(Color.light_gray)
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width, alignment: .topLeading)
                    
                }else{
                    ScrollView{
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width, alignment: .topLeading)
                            .cornerRadius(3)
                            .foregroundColor(Color.light_gray)
                            .overlay(
                                Text(self.ask_content)
                                    //텍스트를 맨 앞에서부터 정렬시키는 것.
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                    .foregroundColor(.proco_black)
                                
                                ,
                                alignment: .topLeading
                            )
                    }
                }
            }
        }
    
    var answer_date: some View{
        HStack{
            Text("답변 날짜")
                .font(.custom(Font.t_extra_bold, size: 14))
                .foregroundColor(Color.proco_black)
            Spacer()
            Text(question_model.processed_date!)
                .font(.custom(Font.n_bold, size: 14))
                .foregroundColor(Color.proco_black)
        }
    }
    
    var answer_content: some View{
            
            VStack{
                HStack{
                    Text("답변 내용")
                        .font(.custom(Font.t_extra_bold, size: 14))
                        .foregroundColor(Color.proco_black)
                    Spacer()
                    
                }
                
                ScrollView{
                    VStack{
                        Rectangle()
                            .frame(minHeight: 50)
                            .cornerRadius(3)
                            .foregroundColor(Color.light_gray)
                            .overlay(
                                Text(question_model.process_content!)
                                    .lineLimit(nil)
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(.proco_black)
                                    .padding([.top,.bottom])
                                ,alignment: .topLeading
                            )
                            
                        
                    }
                }
                
            }
        }
}
