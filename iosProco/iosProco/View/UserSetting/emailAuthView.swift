//
//  emailAuthView.swift
//  proco
//
//  Created by 이은호 on 2020/11/26.
//

import SwiftUI

struct emailAuthView: View {
    @ObservedObject var viewmodel: login_viewmodel
    
    var body: some View {
        VStack{
            //상단바
            HStack{
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                Spacer()
                Text("이메일 인증")
                Spacer()
            }
            .padding(.top, UIScreen.main.bounds.width/20)
            //안내 텍스트
            HStack{
            Text("더 안전한 계정 이용을 위해 2단계 인증을 등록해 주세요")
                .frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width/4)
                .padding()
                Spacer()
            }
            HStack{
                Text("이메일")
                    .fontWeight(.bold)
                    .font(.headline)
                    .padding()
                Spacer()
            }
            TextField("abcd@gmail.com", text: $viewmodel.email_value)
                .padding()
            HStack{
                Spacer()
                Button(action: {
                    
                }, label: {
                    Text("인증번호")
                })
            }
            Divider()
                .frame(height: 2)
                .foregroundColor(Color.orange)
                .padding()
            HStack{
                Text("인증번호")
                    .fontWeight(.bold)
                    .font(.headline)
                    .padding()
                Spacer()
            }
            SecureField("인증번호", text: $viewmodel.auth_number_value)
                .padding()
            Divider()
                .frame(height: 2)
                .foregroundColor(Color.orange)
                .padding()
            Button(action: {
                
            }, label: {
                Text("확인")
            }).frame(maxWidth: .infinity)
            .padding()
            
        }    }
}


