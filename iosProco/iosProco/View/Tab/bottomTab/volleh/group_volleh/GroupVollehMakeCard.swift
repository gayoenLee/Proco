//
//  GroupVollehMakeCard.swift
//  proco
//
//  Created by 이은호 on 2020/11/30.
// ** 키보드 올라올 때 뷰 가리지 않는지 나중에 다시 확인해볼 것

import SwiftUI



struct GroupVollehMakeCard: View {
    @ObservedObject var viewmodel: GroupVollehMainViewmodel

    //모임 소개 텍스트 에디터의 placeholder
    @State var introduce_placeholder = "내용을 입력해주세요"
    
    //추가 완료 후 메인 뷰로 이동하기 위한 토글 값
    @State private var end_plus : Bool = false
    
//    //지도 부분에 사용하는 변수
//    @State var tracking : MapUserTrackingMode = .follow
//    @ObservedObject var managerDelegate = LocationDelegate()
//
//       var currentLocation: CLLocation! // 내 위치 저장
    
    var body: some View {
       
            VStack{
                Group{
                    HStack{
                        Text("모임 이름")
                        Spacer()
                    }
                    .padding()
                    //모임 이름 글자 수 제한 확인할 것
                    //10글자로 제한함.prefix : 최대 길이로 설정된 것까지만 리턴함.
                    TextField("모임 이름을 입력해주세요", text: $viewmodel.card_name)
                        .onReceive(viewmodel.card_name.publisher.collect()){
                            self.viewmodel.card_name = String($0.prefix(10))
                        }
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack{
                        Text("심심태그").font(.subheadline)
                            .padding()
                        Text("필수 선택")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    //카테고리들 세로 리스트
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            
                            ForEach(0..<viewmodel.category_tag_struct.count, id: \.self){ category_index in
                                //태그 카테고리 뷰
                                //1개 클릭시 뷰모델에 user_selected_tag_set에 저장됨.
                                TagCategoryView(vm: self.viewmodel, tag_struct: self.viewmodel.category_tag_struct[category_index])
                                
                            }.padding(.leading, UIScreen.main.bounds.width/30)
                        }
                    }.frame(height: UIScreen.main.bounds.width/5)
                    
                    HStack{
                        TextField("직접입력 (선택사항)", text: $viewmodel.user_input_tag_value)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(Color.gray)
                            .border(Color.black)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                        Button(action: {
                            
                        }){
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/10)
                                .border(Color.gray)
                                .overlay(
                                    Text("추가")
                                        .padding()
                                        .foregroundColor(Color.black))
                                .padding()
                        }
                    }
                }
                
                HStack{
                    Text("날짜")
                        .font(.callout)
                    Spacer()
                    //in: 은 미래 날짜만 선택 가능하도록 하기 위함, displayedComponents는 시간을 제외한 날짜만 캘린더에 보여주기 위함.
                    DatePicker("", selection: $viewmodel.card_date, in: Date()..., displayedComponents: .date)
                        //다이얼로그식 캘린더 스타일
                        .datePickerStyle(CompactDatePickerStyle())
                    Spacer()
                }
                .padding()
                
                HStack{
                    Text("시간")
                        .font(.callout)
                    Spacer()
                    
                    DatePicker("시간을 설정해주세요", selection: $viewmodel.card_time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle( GraphicalDatePickerStyle())
                }
                .padding()

                    HStack{
                        Text("지역")
                        Spacer()
                    }
                    
                    TextField("위치를 입력해주세요", text: $viewmodel.input_location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                      // print("확인 버튼 클릭시 주소 : \(managerDelegate.input_location)")
                        //뷰모델에 저장한 주소를 바탕으로 위도,경도 찾는 메소드 실행.
                        //결과로 coordinate값 얻음. 이를 이용해 setMapView메소드 실행.
                        //그리고 완료되면 지도에 띄운다.
//                        managerDelegate.get_coordinate(address: managerDelegate.input_location)
                   
                    }){
                        Text("확인")
                    }
                    
                    //지도 이미지 나오는 곳*************
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.5, alignment: .center)
                        .foregroundColor(Color.gray)
//                    Map(coordinateRegion: $managerDelegate.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking)
//                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.5, alignment: .center)
               
                Group{
                    HStack{
                        Text("모임 소개")
                        Spacer()
                    }
                    //여러줄의 텍스트 입력을 위해서는 text editor 사용.
                    //text에는 바인딩값만 넣을 수 있음
                    TextEditor(text: self.$viewmodel.input_introduce)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(self.viewmodel.input_introduce == "내용을 입력해주세요" ? .gray : .primary)
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.3)
                        //텍스트 에디터의 placeholder값 넣기 위해
//                        .onAppear{
//                            // 키보드가 나타나면 placeholder값 지움
//                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
//                                withAnimation {
//                                    if self.viewmodel.input_introduce == "내용을 입력해주세요" {
//                                        self.viewmodel.input_introduce = ""
//                                    }
//                                    
//                                }
//                                
//                                
//                                // 사용자가 입력하지 않고 키보드를 다시 내렸을 경우 placeholder 다시 보여줌
//                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
//                                    withAnimation {
//                                        if self.viewmodel.input_introduce == "" {
//                                            self.viewmodel.input_introduce = "내용을 입력해주세요"
//                                        }
//                                    }
//                                }
//                            }
//                        }
                }
            Group{
                HStack{
                    Text("티켓 추가")
                    Spacer()
                }
                //티켓 이미지 rectangle 프레임에 맞춰서 추가시키기
                Rectangle()
                    .overlay(Button(action: {
                        
                    }){
                        Image(systemName: "plus.rectangle.on.rectangle")
                    })
                    .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.4)
                    .foregroundColor(Color.gray)
          
            Spacer()
            Button(action: {
                
                
            }){
                Text("완료")
                    .font(.subheadline)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .border(Color.black, width: 2)
            }
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            }
            .padding()
            }
            .padding()
            //카드 만들기 성공, 실패 결과에 따라 다르게 알림 창 띄움.
            .alert(isPresented: $viewmodel.show_alert){
                switch viewmodel.alert_type{
                case .success:
                    return Alert(title: Text("카드 추가"), message: Text("카드 추가가 완료됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action:{
                        self.end_plus.toggle()
                    }))
                case .fail:
                    return Alert(title: Text("카드 추가"), message: Text("카드 추가를 다시 시도해주세요."), dismissButton: Alert.Button.default(Text("확인"), action:{
                        
                    }))
                }
            }
        .onAppear{
            print("카드 만드는 뷰 넘어옴")
        }
    }
}




