//
//  ContentView.swift
//  Fred
//
//  Created by Justus Languell on 6/15/21.
//
//  Sorry for being ugly I don't write Swift
//  like ever
//
//  Thank god for this
//  https://appiconmaker.co/Home/Index/

import SwiftUI
import Alamofire
import SwiftyJSON
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
    let url: String = rurl + "/post"

    let _headers : HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    let params : Parameters = [
        "usr": usr,
        "msg": msg
    ]

    let req = AF.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: _headers)
    
    req.responseString { (response) in
        //print(response)
        
    }
}

//MARK: - Struct for Messages
struct lineitem: Decodable, Hashable {
    let usr: String
    let msg: String
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

//MARK: - Make shit safe
func makesafe(str: String) -> String {
    var safestr: String = ""
    
    var strchar0: String = ""
    var strchar1: String = ""
    var strchar2: String = ""

    for char in str {
        strchar0 = String(char)
        
        if strchar0 == "”" {
            safestr += "'"
        } else if strchar0 == "“" {
            safestr += "'"
        } else if strchar0 == "”" {
            safestr += "'"
        } else if strchar0 == "{" && strchar1 == "," && strchar2 == "}" {
            safestr = String(safestr.dropLast(2))
        } else {
            
            for subchar in strchar0.unicodeScalars {
                if subchar.isASCII {
                    safestr += strchar0
                } else {
                    //safestr += "�"
                    safestr += ""

                }
            }
        }
        
        strchar2 = strchar1
        strchar1 = strchar0
    }
    return safestr
}

//Inst. Above
let timer = MyTimer()

//MARK: - Main ContentView Struct
struct ContentView: View {
    @State private var msg: String = ""
    @State private var usr: String = ""

    @State var msgs: [lineitem] = []
    @State private var n: Int = 0

    @State private var currentTime: Date = Date()
        
    private let _headers : HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    @State private var params : Parameters = [
        "n": -1
    ]
    
    @Namespace var topID
    @Namespace var bottomID
    
    public let url: String = "https://510f3fcd3c50.ngrok.io"

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
                    
                //Text("\(currentTime)")
                
                ScrollViewReader { proxy in
                    ScrollView {
                        Spacer()
                            .frame(height: 0)
                            .id(topID)
                        
                        VStack(alignment: .leading) {
                            ForEach(msgs, id: \.self) { msgn in
                                Text("\(msgn.usr)")
                                    .bold()
                                    .font(.title2)
                                    .padding(.leading, 5)
                                    .frame(alignment: .leading)
                                    .foregroundColor(.white)
                                
                                Text("\(msgn.msg)")
                                    .font(.title2)
                                    .padding(.leading, 5)
                                    .frame(alignment: .leading)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                    .frame(height: 10)
                                    .id(topID)
                            }
                            .onReceive(timer.currentTimePublisher) {
                                newCurrentTime in self.currentTime = newCurrentTime
                                
                                usr = makesafe(str: usr)
                                msg = makesafe(str: msg)

                                if n < msgs.count {
                                    proxy.scrollTo(bottomID)
                                    n = msgs.count
                                }
                                
                                /*
                                params = [
                                    "n": msgs.count
                                ]
                                */
                                
                                let req = AF.request(url + "/get",
                                                     method: .post,
                                                     parameters: params,
                                                     encoding: URLEncoding.httpBody,
                                                     headers: _headers)
                                
                                req.responseString { response in
                                    //let rawstrresp: String = "{\"Messages\": \"\(response)\"}"
                                    let rawstrresp: String = "\(response)"
                                    var strresp: String = ""
                                    var strchar: String = ""
                                    
                                    for char in rawstrresp {
                                        strchar = String(char)
                                        if strchar != "\\" {
                                            strresp += strchar
                                        }
                                    }
                                    
                                    strresp = String(strresp.dropFirst(9))
                                    strresp = String(strresp.dropLast(2))
                                    let dataresp: Data = Data(strresp.utf8)
                                    do {
                                        let jsonresp: [JSON] = try JSON(data: dataresp).arrayValue
                                        msgs = []
                                        for item in jsonresp {
                                            msgs.append(lineitem.init(usr: item["usr"].stringValue,
                                                                            msg: item["msg"].stringValue))
                                        }
                                        
                                    } catch(_) {
                                        
                                    }
                                } // end scrollview
                                
                            } // end vstack
                            
                            Spacer()
                                .frame(height: 0)
                                .id(bottomID)
                        }
                    }
                        .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
                        .frame(width: getScreenWidth(), alignment: .leading)
                        //.border(Color.blue, width: 1)
                }
                
                HStack {

                    Text("Username")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .frame(width: 80, alignment: .leading)
                        .padding([.top, .leading, .bottom], 10)

                    ZStack {
                        if usr.isEmpty {
                            Text("Username ...").foregroundColor(.gray)
                        }
                        TextField("", text: $usr)
                            .padding(/*@START_MENU_TOKEN@*/[.top, .leading, .bottom]/*@END_MENU_TOKEN@*/, 10)
                            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0)
                            .background(Color.white)
                            .foregroundColor(Color.black)
                    }

                }
                
                HStack {
                    
                    Text("Message")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .frame(width: 80, alignment: .leading)
                        .padding([.top, .leading, .bottom], 10)
                    
                    ZStack {
                        if msg.isEmpty {
                            Text("Message ...").foregroundColor(.gray)
                        }
                    
                        TextField("", text: $msg)
                            .padding([.top, .leading, .bottom], 10)
                            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0)
                            .background(Color.white)
                            .foregroundColor(Color.black)
                    }
                }

                Button("Send Message") {
                    
                    post(rurl: url,
                         usr: usr,
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


