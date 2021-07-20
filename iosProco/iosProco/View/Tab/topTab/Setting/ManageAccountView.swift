//
//  ManageAccountView.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
// 설정에서 넘어온 계정관리 페이지

import SwiftUI

struct ManageAccountView: View {
    //이메일 인증 페이지 이동 구분값
    @State private var go_email_verify: Bool = false
    //비밀번호 변경하기 페이지 이동 구분값
    @State private var go_change_pwd: Bool = false
    //로그아웃 클릭시 알림창 띄우기 위한 구분값
    @State private var ask_logout: Bool = false
    //로그아웃한 사용자를 로그인 페이지로 돌려보내기 위해 화면이동 구분값.
    @State private var logout_ok: Bool = false
    //탈퇴하기 클릭시 알림창 띄우기 위함.
    @State private var exit_click : Bool = false
    //마이페이지 이동 구분값
    @State private var go_my_page  = false
    @StateObject var main_vm: SettingViewModel
    
    //회원탈퇴 글자 입력 제대로 하지 않았을 경우 나타나는 알림창
    @State private var exit_txt_wrong : Bool = false
    
    //회원탈퇴시 오류 발생했을 때 띄울 토스트
    @State private var show_error_toast :Bool = false
    
    var body: some View {
        VStack{
            NavigationLink("",destination: MyPage(main_vm: self.main_vm).navigationBarTitle("마이페이지"), isActive: self.$go_my_page)
            
            NavigationLink("",destination: SettingChangePwdView(main_vm: self.main_vm).navigationBarTitle("비밀번호 변경"), isActive: self.$go_change_pwd)
            
            //로그아웃하는 사용자를 로그인 화면으로 이동시킴.
            NavigationLink("",destination: LoginMenuView().navigationBarBackButtonHidden(true)
                            .navigationBarTitle("", displayMode: .inline).navigationBarHidden(true), isActive: self.$logout_ok)
            
            
            List{
                my_page_btn
                change_pwd_btn
                logout_btn
                exit_btn
            }
        }
        //회원탈퇴 오류 발생시 토스트 띄움
        .overlay(overlayView: Toast.init(dataModel: Toast.ToastDataModel.init(title: "오류", image: "checkmark"), show: self.$show_error_toast), show: self.$show_error_toast)
        
        .navigationBarTitle("계정관리")
        .navigationBarHidden(false)
        .alert(isPresented: self.$exit_txt_wrong){
            Alert(title: Text("알림"), message: Text("입력 단어가 일치하지 않아 탈퇴가 처리되지 않았습니다."), dismissButton: Alert.Button.default(Text("확인")))
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
                    
                    if let user_info = value.userInfo, let data = user_info["logout_event"]{
                        print("[로그아웃] 노티피케이션센터 - 로그아웃 결과 \(data)")
                        
                        if data as! String == "ok"{
                            print("로그아웃 성공")
                            self.logout_ok.toggle()
                        }
                        else{
                            self.show_error_toast = true
                            print("로그아웃 실패")
                        }
                    }
                })
    }
}

private extension ManageAccountView{
    
    var my_page_btn: some View{
        HStack{
            Button(action: {
                
                print("마이페이지 버튼 클릭")
                self.go_my_page.toggle()
                
            }){
                Text("마이 페이지")
                    .font(.custom(Font.n_bold, size: 18))
                    .foregroundColor(Color.proco_black)
            }
            Spacer()
        }
    }
    
    var email_verify_btn: some View{
        HStack{
            
            Button(action: {
                
                print("이메일 인증 버튼 클릭")
                self.go_email_verify.toggle()
                
            }){
                Text("이메일 인증")
                    .font(.custom(Font.n_bold, size: 18))
                    .foregroundColor(Color.proco_black)
            }
            Spacer()
        }
    }
    
    var change_pwd_btn: some View{
        HStack{
            Button(action: {
                print("비밀번호 변경 버튼 클릭")
                self.go_change_pwd.toggle()
            }){
                Text("비밀번호 변경")
                    .font(.custom(Font.n_bold, size: 18))
                    .foregroundColor(Color.proco_black)
            }
            Spacer()
        }
    }
    
    var logout_btn: some View{
        HStack{
            
            Button(action: {
                
                print("로그아웃 버튼 클릭")
                self.ask_logout.toggle()
                
            }){
                Text("로그아웃")
                    .font(.custom(Font.n_bold, size: 18))
                    .foregroundColor(Color.proco_black)
            }
            .alert(isPresented: self.$ask_logout){
                Alert(title: Text("로그아웃"), message: Text("정말 로그아웃 하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                    
                    self.main_vm.logout()
                }), secondaryButton: Alert.Button.cancel(Text("취소"), action: {
                    self.ask_logout = false
                }))
            }
            Spacer()
        }
    }
    
    var exit_btn: some View{
        
        HStack{
            Button(action: {
                print("회원탈퇴 버튼 클릭")
                self.exit_click.toggle()
                
            }){
                Text("회원 탈퇴")
                    .font(.custom(Font.n_bold, size: 18))
                    .foregroundColor(Color.proco_black)
            }
            Spacer()
        }
        .alert(isPresented: self.$exit_click,
               ExitAlert(title: "회원탈퇴", message: "정말로 탈퇴하시겠습니까? \n '회원탈퇴'를 입력해주세요", keyboardType: .default){result in
                
                if result == "회원탈퇴"{
                    print("회원탈퇴 글자 같음.")
                    //회원탈퇴 글자를 정확히 입력했으므로 회원 탈퇴 통신, 로그인 화면으로 보냄.
                    self.main_vm.delete_exit_user()
                    
                }else{
                    print("회원 탈퇴 처리 안함.글자 같지 않음.")
                    self.exit_txt_wrong = true
                }
               })
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            
            if let user_info = value.userInfo,  let check_result = user_info["delete_exit_user"]{
               
                
                print("회원 탈퇴 처리 데이터 확인: \(String(describing: check_result))")
                
                //회원 탈퇴한 경우
                 if check_result as! String == "ok"{
                 
                    self.logout_ok = true
                }else if check_result as! String == "error"{
                    
        
                }
            }
            
        })
    }
}


extension View {
    public func alert(isPresented: Binding<Bool>, _ alert: ExitAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}
public struct ExitAlert{
    public var title: String // Title of the dialog
    public var message: String // Dialog message
    public var placeholder: String = "" // Placeholder text for the TextField
    public var accept: String = "OK" // The left-most button label
    public var cancel: String? = "Cancel" // The optional cancel (right-most) button label
    public var secondaryActionTitle: String? = nil // The optional center button label
    public var keyboardType: UIKeyboardType = .default // Keyboard tzpe of the TextField
    public var action: (String?) -> Void // Triggers when either of the two buttons closes the dialog
    public var secondaryAction: (() -> Void)? = nil // Triggers when the optional center button is tapped
}

extension UIAlertController {
    convenience init(alert: ExitAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
        addTextField {
            $0.placeholder = alert.placeholder
            $0.keyboardType = alert.keyboardType
        }
        if let cancel = alert.cancel {
            addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
                alert.action(nil)
            })
        }
        if let secondaryActionTitle = alert.secondaryActionTitle {
            addAction(UIAlertAction(title: secondaryActionTitle, style: .default, handler: { _ in
                alert.secondaryAction?()
            }))
        }
        let textField = self.textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            alert.action(textField?.text)
        })
    }
}
struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: ExitAlert
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }
    
    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.isPresented = false
                self.alert.action($0)
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}
