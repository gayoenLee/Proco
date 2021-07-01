//
//  ProcoMainCalendarView.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//

import SwiftUI
import ProcoCalendar

struct ProcoMainCalendarView: View {

    @ObservedObject private var calendarManager: ElegantCalendarManager
    @ObservedObject var main_vm : CalendarViewModel
    //날짜 한 칸 일정 리스트 데이터
    @State var smallSchedulesByDay: [Date: [SmallSchedule]]
    
    //일 상세페이지 관심있어요 아이콘 뷰를 위한 데이터
    var InterestByDay: [Date: [InterestModel]]
    
    //하루 상세 페이지 뷰 일정 리스트 데이터
    var schedule_by_day: [Date: [Schedule]]
    
    //날짜 한 칸 관심있어요 아이콘 뷰를 위한 데이터
    var small_interest_by_day : [Date : [SmallInterestModel]]
    
    let calendar_owner_data : CalendarOwnerModel
    
    @State private var go_mypage : Bool = false
    @State private var go_setting_page : Bool = false
    
    //boring days
    //여기에서 받은 boring days를 elegant calendar manager에 넘겨줘서 monthly calendar manager에서 사용할 수 있게 하는 것.
    init(ascSmallSchedules: [SmallSchedule], initialMonth: Date?, ascSchedules: [Schedule], ascInterest: [InterestModel],boring_days: [Date], main_vm: CalendarViewModel, ascSmallInterest: [SmallInterestModel], calendarOwner: CalendarOwnerModel, go_mypage: Bool?,previousMonth : Date, go_setting_page: Bool?) {
        //여기에서 value가 연도 달력에서 몇년도까지 날짜를 셋팅할   인지 설정하는 것.
        let configuration = CalendarConfiguration(
            calendar: currentCalendar,
            startDate: Calendar.current.date(byAdding: .day, value: -360*2, to: initialMonth!)!,
            endDate: Calendar.current.date(byAdding: .day, value: 360*2, to: initialMonth!)!)
        print("순서2. 프로코 메인 캘린더뷰에서 init안 initial month")
       // print("프로코 메인 캘린더뷰 Schedule 데이터 확인: \(ascSchedules)")
        
        calendarManager = ElegantCalendarManager(
            configuration: configuration,
            initialMonth: initialMonth, selections: boring_days, owner_idx: calendarOwner.user_idx, owner_photo_path: calendarOwner.profile_photo_path, owner_name: calendarOwner.user_nickname, watch_user_idx: calendarOwner.watch_user_idx, go_mypage: go_mypage ?? false, previousMonth: previousMonth, go_setting_page: go_setting_page ?? false)
       
        schedule_by_day = Dictionary(
            grouping: main_vm.schedules_model,
            by: { currentCalendar.startOfDay(for: $0.date) })
        
        InterestByDay = Dictionary(
            grouping: ascInterest,
            by: { currentCalendar.startOfDay(for: $0.date!) })
     
        smallSchedulesByDay = Dictionary(
            grouping: main_vm.small_schedules,
            by: { currentCalendar.startOfDay(for: $0.arrivalDate) })
        
        small_interest_by_day = Dictionary(grouping: ascSmallInterest, by: {currentCalendar.startOfDay(for: $0.date!)})
        
        //캘린더 주인 프로필 사진, 이름 상단에 보여줘야 해서 추가.
        calendar_owner_data = CalendarOwnerModel(user_idx: calendarOwner.user_idx, profile_photo_path: calendarOwner.profile_photo_path, user_nickname: calendarOwner.user_nickname)
        self.main_vm = main_vm
        self.go_mypage = go_mypage ?? false
        self.go_setting_page = go_setting_page ?? false
        
        calendarManager.datasource = self
        calendarManager.delegate = self
    }
    
    var body: some View {
        
        VStack{
            NavigationLink("",destination: MyPage(main_vm: SettingViewModel()), isActive: self.$go_mypage)
            ZStack{
                VStack{
                
                ProcoCalendarView(calendarManager: calendarManager)
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarHidden(true)
                    .onAppear{
                        print("캘린더 뷰 proco main calendar view on appear 들어옴:\(self.main_vm.calendar_owner) ")
                        self.main_vm.schedule_state_changed = true
                    }
                    .onDisappear{
                        self.main_vm.schedule_state_changed = false
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.calendar_owner_click), perform: {value in
                        print("캘린더 설정 클릭 이벤트 받음")
                        
                        if let user_info = value.userInfo, let data = user_info["calendar_setting_click"]{
                            print("캘린더 설정 버튼  클릭 이벤트 \(data)")
                            
                            if data as! String == "ok"{
                                self.main_vm.get_detail_user_info(user_idx: Int(self.main_vm.my_idx!)!)
                                
                                print("설정 페이지 이동값 변경하기")
                            }
                        }else{
                            print("설정 페이지 이동 노티 아님")
                        }
                    })
                    .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
                        
                        if let user_info = value.userInfo, let data = user_info["got_calendar_alarm_info"]{
                            print("캘린더 설정 - 유저 정보 노티 \(data)")
                            
                            if data as! String == "ok"{
                                
                                self.go_setting_page = true
                            
                            }
                        }else{
                            print("그룹관리 - 친구 리스트 데이터 노티 아님")
                        }
                    })
                  
                Spacer()
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        
                        if calendar_owner_data.user_idx == Int(self.main_vm.my_idx!)!{
                            
                        ZStack(alignment: .bottom){  //일정 추가하는 버튼
                            PlusScheduleButtonView(main_vm: self.main_vm)
                            
                        }
                        }
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.width*0.2)
                .padding(.trailing, UIScreen.main.bounds.width/20)
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
        }
        .onAppear{
            self.go_setting_page = false
            print("프로코메인캘린더뷰 나타남 calendar owner data:\(calendar_owner_data)")
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .frame(height: UIScreen.main.bounds.height*0.8, alignment: .top)
        .sheet(isPresented: self.$go_setting_page){
            FeedDisclosureSettingView(main_vm: self.main_vm)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.calendar_personal_schedule), perform: {value in
            print("개인 스케줄 추가 노티 받음.")

            if let user_info = value.userInfo, let data = user_info["add_calendar_schedule"]{
                print("개인 스케줄 추가 노티 데이터 \(data)")

                if data as! String == "new_ok"{

                let schedule_date = user_info["schedule_date"] as! String
                    let date_form = self.main_vm.make_date(expiration: schedule_date)
                    self.main_vm.schedules_model.removeAll()
              let schedule_info = user_info["data"] as! [ScheduleInfo]
                    self.main_vm.schedules_model.append(Schedule(date: date_form, like_num: 0, liked_myself: false, like_idx: -1, schedule: schedule_info))
                print("개인 스케줄 추가 후 데이터 모델에 넣음: \(schedule_info)")

                    calendarManager.objectWillChange.send()
//                    self.main_vm.schedule_start_date = Date()
//                    self.main_vm.schedule_start_time = Date()
                }else if data as! String == "already_exist_ok"{
                    
                    print("개인일정 이미 있던 경우")
                    let schedule_data = user_info["data"] as! ScheduleInfo
                    let model_idx = user_info["model_idx"] as! String
                    self.main_vm.schedules_model.removeAll()

                    self.main_vm.schedules_model[Int(model_idx)!].schedule.append(schedule_data)
                    calendarManager.objectWillChange.send()

//                    self.main_vm.schedule_start_date = Date()
//                    self.main_vm.schedule_start_time = Date()
                }
            }else{
                print("개인 스케줄 추가 노티 아님")
            }
        })
    }
    
}

extension ProcoMainCalendarView: ElegantCalendarDataSource {
        
    func calendar(backgroundColorOpacityForDate date: Date) -> Double {
        let startOfDay = currentCalendar.startOfDay(for: date)
        return Double((smallSchedulesByDay[startOfDay]?.count ?? 0) + 3) / 15.0
    }
    
    func calendar(canSelectDate date: Date) -> Bool {
        let day = currentCalendar.dateComponents([.day], from: date).day!
        return day != 4
    }
    
    //내 일정이 있는지 여부를 알기 위해 만듬.-> dayview에서 날짜 한 칸에 내 일정 아이콘 보여주는데 사용.
    func calendar(myScheduleDate date: Date) -> Bool{
       
        var check_idx : Int? = -1
        
        //schedule모델 안에 personal타입의 데이터가 저장돼 있는지 체크하기 위해 firstindex를 갖고 오는 것.
        check_idx = schedule_by_day[date]?.firstIndex(where: {
            $0.schedule.contains(where: {
                $0.type == "personal"
            })
        }) ?? -1
        //갖고 온 first index가 있으면 true
        if check_idx != -1{
            print("내 일정이 있는지 여부 메소드 안 일정 있는 경우 true: \(schedule_by_day[date]![check_idx!])")
            return true
            
        }else{
            return false
        }
    }
    
    func calendar(viewForSelectedDate date: Date, dimensions size: CGSize) -> AnyView {
        let startOfDay = currentCalendar.startOfDay(for: date)
        //print("startOfDay 확인: \(startOfDay), \(String(describing: smallSchedulesByDay[startOfDay])), smallschedules\(smallSchedulesByDay)")
        
        if self.main_vm.calendar_like_changed == true{
            print("좋아요 클릭시 뷰 데이터: \(main_vm.small_schedules)")

            self.main_vm.calendar_like_changed = false

        }else{
            //print("좋아요 클릭 안했을 때 날짜 뷰")
        }
            return SmallScheduleListView(main_vm: self.main_vm, smallSchedules: smallSchedulesByDay[startOfDay] ?? [], height: size.height).erased
       
    }
    
    //날짜 한 칸 관심있어요 뷰 리턴하는 메소드
    func calendar(viewForSmallInterest date: Date, dimensions size: CGSize) -> AnyView{
        let startOfDay = currentCalendar.startOfDay(for: date)
        return SmallInterestView(main_vm: self.main_vm,  small_intrest_model:  small_interest_by_day[startOfDay] ?? [], height: size.height).erased
    }
    
    //하루 일정 상세 뷰에서 사용하는 메소드
    func calendar(viewForScheduleDate date: Date, dimensions size: CGSize) -> AnyView {
        print("ExampleCalendarView 에서 schedule뷰 리턴")
        let startOfDay = currentCalendar.startOfDay(for: date)
        return ScheduleListView(schedules: schedule_by_day[startOfDay] ?? [],  main_vm: self.main_vm, height: size.height).erased
    }
    
    //상세 페이지 관심있어요 버튼 뷰 리턴하는 메소드
    func calendar(viewForInterest date: Date, dimensions size: CGSize) -> AnyView {
        print("ExampleCalendarView 에서 관심있어요 뷰 리턴")
        let startOfDay = currentCalendar.startOfDay(for: date)
        return InterestView(main_vm: self.main_vm, intrest_total_model: InterestByDay[startOfDay] ?? [], height: size.height).erased
    }
    
    
}

extension ProcoMainCalendarView: ElegantCalendarDelegate {
    
    func calendar(didSelectDay date: Date) {
        print("Selected date: \(date)")
    }
    
    func calendar(willDisplayMonth date: Date, previousMonth: Date) {
        print("순서6.-------프로코 메인 캘린더뷰----------")
            
        
        //스크롤해서 움직인 달의 정보
        let scrolled_date = Calendar.current.date(byAdding: .hour, value: 9, to: date)
        print("스크롤 날짜 확인: \(scrolled_date)")

    }
    
    func calendar(didSelectMonth date: Date) {
        print("Selected month: \(date)")
    }
    
    func calendar(willDisplayYear date: Date) {
        print("프로코 메인 캘린더뷰에서 will display year")
        print("Year displayed: \(date)")
        
    }
    
    //심심기간 설정 완료시 호출할 메소드
    //end: 심심기간 설정이 완료됐음을 알리기 위한 boolean값.
    func calendar(didEditBoringPeriod selections: [Date],end: Bool){
        print("기간 설정 완료")
        
        /*
         api v1.133번째 줄
         서버에 보낼 데이터 형식 만들기
         1. selections배열 string화하기 : string_selections
         2.string_selections에서 년,월까지만 가져온 후 month_string배열 만들기: bored_date를 따로 보내야 하므로 필요, 해당 달에 대한 날짜 정보 비교해서 가져오기 위해 필요
         3.bored_date_days: string_selections이용해 해당 달에 대한 날짜 배열 만들기
         4.date_array_model에 달별로 append
         */
        //서버에 보낼 최종 모델
        var bored_date_model : [EditBoringDatesModel] = []
        
        //1.날짜들 string화하기
        var string_selections : [String] = []
        for day in selections{
            string_selections.append(main_vm.date_to_string(date: day))
        }
        //2.2021-02형식 만들기
        var month_string_array : [String] = []
        for month in string_selections{
            let year = month.split(separator: "-")[0]
            let month = month.split(separator: "-")[1]
            let year_month = "\(year)-\(month)"
            month_string_array.append(year_month)
        }
        //3.해당 달에 대한 날짜만으로 배열 만들기
        
        for month in month_string_array{
            print("비교할 달: \(month)")
            var bored_date_days: [Int] = []
            for day in string_selections{
                print("비교하려는 날짜: \(day)")
                if day.contains(month){
                    print("해당 달에 대한 날짜임: \(day), 월정보: \(month)")
                    var date_info = day.split(separator: "-")[2]
                    print("해당 달에  날짜 split한 값: \(date_info)")
                    print("해당 달에  날짜 split한 값222: \(date_info[date_info.startIndex])")
                    
                    if date_info[date_info.startIndex] == "0"{
                        
                        date_info.remove(at: date_info.startIndex)
                        print("한자리 숫자일 때 0뺸 값: \(date_info)")
                        
                    }
                    bored_date_days.append(Int(date_info)!)
                }
            }
            //bored_date : "2021-02-00"형식, bored_date_days: [1,2,3]형식
            var bored_date : String  = ""
            bored_date = "\(month)-01"
            
            bored_date_model.append(EditBoringDatesModel( bored_date: bored_date, bored_date_days: bored_date_days))
        }
        print("최종으로 저장한 심심기간 배열: \(bored_date_model)")
        if !bored_date_model.isEmpty{
            main_vm.send_boring_period_events(date_array: bored_date_model)
        }
    }
    
}

extension Calendar{
    
    func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay(for: date))!
    }
}

