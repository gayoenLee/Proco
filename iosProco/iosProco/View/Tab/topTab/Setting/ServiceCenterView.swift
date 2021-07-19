//
//  ServiceCenterView.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
//

import SwiftUI

struct ServiceCenterView: View, ServiceCenterProtocol {
    //디폴트 메뉴명
    @State private var selected_menu = "문의하기"
    var menus = ["문의하기", "내 문의내역"]
    //문의 내용 입력 hint
    @State var ask_content: String = ""
    @ObservedObject var main_vm: SettingViewModel
    
    var body: some View {
      
        VStack{
           
            Picker(selection: $selected_menu, label: Text("메뉴")){
                ForEach(menus, id: \.self){
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle())
            .padding()
           
            if selected_menu == "문의하기"{
                ask_view
            }else{
                //문의한 내역이 없는 경우 예외처리
                if main_vm.question_model.count > 0{
                    
                ForEach(main_vm.question_model.indices, id: \.self){question in
                    MyQuestionCellView(main_vm: self.main_vm, question_model: main_vm.question_model[question])
                    Divider()
                       
                }
                }else{
                    Text("문의한 내역이 없습니다.")
                        .font(.custom(Font.n_bold, size: 14))
                        .foregroundColor(Color.gray)
                }
            }
            Spacer()
        }
        .navigationBarTitle("문의하기")
        .font(.custom(Font.n_extra_bold, size: 22))
        .foregroundColor(Color.proco_black)
        .onAppear{
            //내 문의내역 갖고 오는 통신
            main_vm.get_my_questions()
        }
    }
}

protocol ServiceCenterProtocol {
    var ask_content: String{ get set }
}

extension UIApplication {
   func endEditing() {
       sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

private extension ServiceCenterView {
    //문의내용 입력 칸
    var ask_view: some View {
        VStack{
            HStack{
        Text("프로코에게 문의 사항을 보내주세요")
            .font(.custom(Font.n_bold, size: 14))
            .foregroundColor(Color.proco_black)
                Spacer()
            }
            
            HStack{
                
            Text("답변에는 시간이 소요될 수 있습니다.")
                .font(.custom(Font.n_bold, size: 11))
                .foregroundColor(Color.light_gray)
                Spacer()
            }
                     
        TextEditor(text: $ask_content)
            .font(.custom(Font.n_bold, size: 14))
            .foregroundColor(Color.proco_black)
            .colorMultiply(Color.light_gray)
            .cornerRadius(3)
            .background(Color.light_gray)
            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width, alignment: .center)
            
            Spacer()
            Button(action: {
                print("문의하기 확인 클릭")
                //문의하기 생성 통신
                main_vm.send_question_content(content: ask_content)
                main_vm.request_result_alert_func(main_vm.request_result_alert)
            
            }){
               Text("확인")
                .font(.custom(Font.t_extra_bold, size: 15))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.proco_white)
                .background(Color.proco_black)
                .cornerRadius(25)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
                    
            }
            .alert(isPresented: $main_vm.show_result_alert){
                switch main_vm.request_result_alert{
                case .make, .edit:
                    return Alert(title: Text("문의하기"), message: Text("등록되었습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                        //문의하기가 생성된 후 문의내역 리스트로 이동시킴.
                        self.selected_menu = "내 문의내역"
                        
                    }))
                case .delete:
                    return Alert(title: Text("문의하기"), message: Text("삭제되었습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                        
                    }))
                case .fail:
                    return Alert(title: Text("문의하기"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    }))
                }
            }
        }
        //키보드 올라왓을 때 화면 다른 곳 터치하면 키보드 내려가는 것
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        .padding()
    }
    
    var my_question_list_view : some View{

        ForEach(main_vm.question_model.indices, id: \.self){question in
                MyQuestionCellView(main_vm: self.main_vm, question_model: main_vm.question_model[question])
            }
    }
    
    var question_detail_view: some View{
        
        VStack{
            Text("문의 내용")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.proco_black)

            Spacer()
            
            TextEditor(text: $ask_content)
                .font(.system(size: 20, weight: .regular, design: .default))
                      .clipShape(RoundedRectangle(cornerRadius: 12))
                      .foregroundColor(.proco_black)
                .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width, alignment: .center)
                
                Spacer()
                Button(action: {
                    print("문의하기 확인 클릭")
                    //문의하기 생성 통신
                    main_vm.send_question_content(content: ask_content)
                    main_vm.request_result_alert_func(main_vm.request_result_alert)
                
                }){
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width/20, alignment: .center)
                        .foregroundColor(Color.blue)
                        .overlay(Text("확인")
                                    .foregroundColor(Color.black))
                }
                .alert(isPresented: $main_vm.show_result_alert){
                    switch main_vm.request_result_alert{
                    case .make, .edit:
                        return Alert(title: Text("문의하기"), message: Text("등록되었습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .delete:
                        return Alert(title: Text("문의하기"), message: Text("삭제되었습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .fail:
                        return Alert(title: Text("문의하기"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    }
                }
        }
    }
}

struct MyQuestionCellView:  View{
    
    @ObservedObject var main_vm: SettingViewModel
    let question_model : MyQuestionModel
    //문의하기 상세페이지 이동
    @State var go_to_detail: Bool = false
    
    var body: some View{
        VStack{
            NavigationLink("",destination: MyQuestionDetailView(question_model: question_model, main_vm: main_vm), isActive: self.$go_to_detail)
            
            HStack{
            Text(question_model.content)
                .lineLimit(1)
                .font(.custom(Font.n_bold, size: 14))
                .foregroundColor(Color.proco_black)
                
                Spacer()
                
                if question_model.process_content == ""{
                  
                            Text("답변대기")
                                .padding(UIScreen.main.bounds.width/25)
                                .font(.custom(Font.t_extra_bold, size: 10))
                                .foregroundColor(.proco_white)
                                .background(Color.gray)
                                .cornerRadius(25)
                                .padding([.trailing], UIScreen.main.bounds.width/25)
                             
                       
                }else{
                            Text("답변완료")
                                .padding(UIScreen.main.bounds.width/25)
                                .font(.custom(Font.t_extra_bold, size: 10))
                                .foregroundColor(.proco_white)
                                .background(Color.proco_green)
                                .cornerRadius(25)
                                .padding([.trailing], UIScreen.main.bounds.width/25)
                }
                
            }
            .padding(.leading)
            
            HStack{
               
                Text(question_model.created_at!.split(separator: " ")[0])
                .font(.custom(Font.n_bold, size: 13))
                .foregroundColor(Color.gray)
                    .padding(.leading)
                
            Spacer()
            }
        } .onTapGesture {
            self.go_to_detail.toggle()
            print("한개 클릭")
        }
    }
}
