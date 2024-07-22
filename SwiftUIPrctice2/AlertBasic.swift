//
//  AlertBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/21/24.
//

import SwiftUI

struct AlertBasic: View {
    
    @State var showAlert1: Bool = false
    @State var showAlert2: Bool = false
    @State var showAlert3: Bool = false
    @State var showAlert4: Bool = false
    
    @State var backgroundColor: Color = Color.yellow
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var alertType: AlertCase? = nil
    
    enum AlertCase {
        case sucess
        case error
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack (spacing: 20) {
                Button(action: {
                    showAlert1.toggle()
                }, label: {
                    Text("1번 알럿")
                })
                .alert(isPresented: $showAlert1, content: {
                    Alert(title: Text("패스워드 에러입니다. 다시 확인하세요."))
                })
                
                Button(action: {
                    showAlert2.toggle()
                }, label: {
                    Text("2번 알럿")
                })
                .alert(isPresented: $showAlert2, content: {
                    getAlert2()
                })
                
                HStack (spacing: 10){
                    Button(action: {
                        alertTitle = "영상이 업로드 에러"
                        alertMessage = "영상이 제대로 올라가지 않았습니다."
                        showAlert3.toggle()
                    }, label: {
                        Text("3번 알럿 실패시")
                    })
                    
                    Button(action: {
                        alertTitle = "영상이 업로드 성공"
                        alertMessage = "영상이 성공적으로 업로드 되었습니다."
                        showAlert3.toggle()
                    }, label: {
                        Text("3번 알럿 성공")
                    })
                }
                .alert(isPresented: $showAlert3, content: {
                    getAlert3()
                })
                
                HStack (spacing: 10){
                    Button(action: {
                        alertType = .error
                        showAlert4.toggle()
                    }, label: {
                        Text("4번 알럿 실패시")
                    })
                    
                    Button(action: {
                        alertType = .sucess
                        showAlert4.toggle()
                    }, label: {
                        Text("4번 알럿 성공")
                    })
                }
                .alert(isPresented: $showAlert4, content: {
                    getAlert4()
                })
            } //VSack
        }//ZStack
    }//body
    
    //fuction
    func getAlert2() -> Alert {
        return Alert(
            title: Text("메세지 삭제"),
            message: Text("정말 메세지를 삭제하겠습니까?"),
            primaryButton: .destructive(Text("Delete"), action: {
                backgroundColor = .red
            }),
            secondaryButton: .cancel())
    }
    
    func getAlert3() -> Alert {
        return Alert(
            title: Text(alertTitle),
            message: Text(alertMessage),
            dismissButton: .default(Text("OK")))
    }
    
    func getAlert4() -> Alert {
        switch alertType {
        case .error:
            return Alert(title: Text("에러발생"), dismissButton: .default(Text("OK"), action: {
                backgroundColor = .red
            }))
        case .sucess:
            return Alert(title: Text("로그인에 성공 했습니다."), dismissButton: .default(Text("OK"), action: {
                backgroundColor = .green
            }))
        default:
            return Alert(title: Text("기본값"))
        }
    }
}

#Preview {
    AlertBasic()
}
