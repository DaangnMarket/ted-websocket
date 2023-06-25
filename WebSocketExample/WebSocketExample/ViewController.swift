//
//  ViewController.swift
//  WebSocketExample
//
//  Created by KimTaeHyung on 2023/06/25.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBlue
        
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        let url = URL(string: "wss://s9309.blr1.piesocket.com/v3/1?api_key=cZGOksfuE6CqV1cZfly2CnFBqbE33D1UBzTWgUvd&notify_self=1")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
    }
    
    //ping을 통해 webSocket이 잘 연결되고 있는지 확인
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    
    //connection이 끝났을 때 대한 이유
    func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    //
    func send() {

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.send()
            self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...1000))"), completionHandler: { error in
                if let error = error {
                    print("send error: \(error)")
                }
            })
        }
    }
    
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in   //weak self : 메모리 누수 방지
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got Data: \(data)")
                case .string(let message):
                    print("Got String: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            
            //receive를 계속 부를 것이기 때문에
            self?.receive()
        })
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason \((reason))")
    }
    
}
