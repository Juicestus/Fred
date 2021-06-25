//
//  ContentView.swift
//  Fred
//
//  Created by Justus Languell on 6/15/21.
//

import SwiftUI
import Alamofire
import Combine

//MARK: - Main Screen Width
func getScreenWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

//MARK: - Main Screen Height
func getScreenHeight() -> CGFloat {
    return UIScreen.main.bounds.height
}


//MARK: - Send A Post Request To Server
func post(rurl: String, usr: String, msg: String) {
    var url: String = url + "/post"

    let _headers : HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    let params : Parameters = [
        "usr": usr,
        "msg": msg
    ]

    var req = AF.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: _headers)
    
    req.responseString { (response) in print(response)}
}

//MARK: - Get Messages From The Server
func get(rurl: String, n: Int) {
    var url: String = url + "/get"
    
    let _headers : HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    let params : Parameters = [
        "msgs": n
    ]

    var req = AF.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: _headers)
    
    req.responseString { (response) in print(response)}
}

//MARK: - Timer Object I Got From Stack Overflow
class MyTimer {
    let currentTimePublisher = Timer.TimerPublisher(interval: 0.1, runLoop: .main, mode: .default)
    let cancellable: AnyCancellable?

    init() {
        self.cancellable = currentTimePublisher.connect() as? AnyCancellable
    }

    deinit {
        self.cancellable?.cancel()
    }
}

//Inst. Above
let timer = MyTimer()

//MARK: - Main ContentView Struct
struct ContentView: View {
    @State private var msg: String = ""
    @State var msgs: [String] =
        ["Msg 1", "Msg 2", "Msg 3"]
    @State private var n: Int = 3
    
    @State private var currentTime: Date = Date()
        
    public var url: String = "https://16b545e7ac34.ngrok.io"
    //"https://webhook.site/6dfae465-452c-4e15-824a-6f618e77938c"
        
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading) {
                Text("Fred 1.0")
                    .bold()
                    .foregroundColor(.blue)
                    .font(.largeTitle)
                    .frame(width: getScreenWidth(), height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding(.bottom)
                    
                Text("\(currentTime)").onReceive(timer.currentTimePublisher) {
                    newCurrentTime in self.currentTime = newCurrentTime
                    n = msgs.count
                    msgs.append("Msg \(n+1)")
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(msgs, id: \.self) { msgn in
                            Text("\(msgn)")
                                .bold()
                                .font(.title2)
                                .padding(.all, 5)
                                .frame(alignment: .leading)
                                .foregroundColor(.white)
                            
                        }
                    }
                }
                    .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
                    .frame(width: getScreenWidth(), alignment: .leading)
                    .border(Color.blue, width: 2)
                    
                    TextField("Message ...", text: $msg)
                        .padding(/*@START_MENU_TOKEN@*/[.top, .leading, .bottom]/*@END_MENU_TOKEN@*/)
                        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0)
                        .background(Color.white)
                
                    Button("Send Message") {
                        post(url: url,
                             usr: "Anon",
                             msg: msg)
                        msg = ""
                    }
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(alignment: .center)
                
                
                    
            }
            .padding(.all, 100)
        }
        .accentColor(Color.black)
    }
    
}

//MARK: - I Dont Know What The Fuck This Does

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
