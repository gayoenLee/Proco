//
//  signup_personal_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/10.
//

import SwiftUI

struct SignupPersonalView: View {
    @Environment(\.presentationMode) var presentation
    
    //회원정보 담는 클래스
    @ObservedObject var info_viewmodel :  SignupViewModel
    //선택한 날짜 정보
    @State private var selectedDate = Date()
    //선택한 gender정보 담는 변수
    @State var selected_gender_set = Set<String>()
    //date string으로 변경
    @State var string_date: String = ""
    var body: some View {
        
        VStack(alignment: .center){
            HStack{
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    
                }){
                    Image("left")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
                Spacer()
                Text("개인정보 입력")
                    .font(.custom(Font.n_extra_bold, size: 20))
                    .foregroundColor(Color.proco_black)
                Spacer()
            }
            .padding()
            
            HStack{
                GenderSelectButtons(personal_info_viewmodel: self.info_viewmodel, selected_gender: false)
            }
            .padding(UIScreen.main.bounds.width/10)
          
         
            Spacer()
            NavigationLink(
                destination: SignupProfileView(info_viewmodel: self.info_viewmodel)
            ){
                Text("다음")
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.proco_white)
                    .background(Color.proco_black)
                    .cornerRadius(25)
                    .padding([.leading, .trailing, .bottom], UIScreen.main.bounds.width/25)
            }
            .navigationBarTitle("")
            .padding(.bottom, UIScreen.main.bounds.width/20)
            //화면 사라질 때 마케팅 동의한 여부값 저장하기
            .onDisappear(perform: {
                print("퍼스널뷰에서 핸드폰 번호 확인 : \(self.info_viewmodel.phone_number)")
                //다음 페이지로 갈 때 생년월일을 string으로 변환하는 메소드 실행
//                let formatter = DateFormatter()
//                string_date = formatter.string(from: self.info_viewmodel.birth)
//                self.info_viewmodel.birth_string = string_date
            })
            Spacer()
            //vstack끝
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background( Image("signup_fourth")
                        .resizable()
                        .scaledToFill())
    }
}

struct GenderSelectButtons: View{
    @ObservedObject var personal_info_viewmodel :  SignupViewModel
    
    //선택한 성별 정보, 모델에 저장할 값
    //현재 선택한 값이 true일 때 여성.
    @State var selected_gender: Bool
    //예외처리 위해 만든 set
    @State var selected = Set<String>()
    var selected_set : Bool{
        selected.contains("")
    }
    
    var body: some View{
        HStack(alignment: .center){
            Spacer()
            //이미 선택한 것을 다시 클릭했을 때
            //현재 선택한 gender와 지금 클릭한 gender가 같을 때 회색
            
            Button(action: {
                selected_gender.toggle()
                
                selected.remove("women")
                selected.insert("men")
                
                print(selected, selected_gender)
            }){
                VStack{
                    Image(selected.contains("men") ? "men_active" : "men_inactive")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width/2.5, height: UIScreen.main.bounds.width/2.5)
                    
                }
            }
            Spacer()
            //여성
            Button(action: {
                selected_gender.toggle()
                selected.remove("men")
                selected.insert("women")

                print(selected, selected_gender)
            }){
                VStack{
                    Image(selected.contains("women") ? "women_active" : "women_inactive")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width/2.5, height: UIScreen.main.bounds.width/2.5)
                    
                }
            }
            Spacer()
            
        }
        
    }
}




