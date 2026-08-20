//
//  SignallingClient.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-09.
//
import Foundation

class SignalingClient: NSObject, URLSessionWebSocketDelegate {
    private var session: URLSession?
    private var webSocket: URLSessionWebSocketTask?
    private let serverURL: URL
    private var userId: String?
    private weak var webRTCManager: WebRTCManager?
    var currentCallPartner: String?
    
    init(webRTCManager: WebRTCManager) {
        self.webRTCManager = webRTCManager
        // Must match the HTTPS host. A TLS server on 8080 requires wss://, not ws://.
        self.serverURL = URL(string: "wss://0bsadh7ysww0.shares.zrok.io/ws")!
        super.init()
    }
    
    func connect(userId: String) {
        self.userId = userId
        
        print("🔌 Connecting to WebSocket at: \(serverURL)")
        
        session?.invalidateAndCancel()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        self.session = session
        webSocket = session.webSocketTask(with: serverURL)
        webSocket?.resume()
        
        listenForMessages()
    }
    
    private func sendRegister() {
        guard let userId = userId else { return }
        let registerDict: [String: Any] = [
            "type": "register",
            "payload": ["userId": userId]
        ]
        send(registerDict)
    }
    
    func sendCall(to userId: String, sdp: String) {
        currentCallPartner = userId
        let callDict: [String: Any] = [
            "type": "call",
            "to": userId,
            "payload": ["sdp": sdp]
        ]
        send(callDict)
    }
    
    func sendAnswer(to userId: String, sdp: String) {
        let answerDict: [String: Any] = [
            "type": "answer",
            "to": userId,
            "payload": ["sdp": sdp]
        ]
        send(answerDict)
    }
    
    func sendICECandidate(to userId: String, candidate: String, sdpMid: String, sdpMLineIndex: Int32) {
        let iceDict: [String: Any] = [
            "type": "ice-candidate",
            "to": userId,
            "payload": [
                "candidate": candidate,
                "sdpMid": sdpMid,
                "sdpMLineIndex": sdpMLineIndex
            ]
        ]
        send(iceDict)
    }
    
    func sendPath(to userId: String, path: [UserPath]) {
        guard let pathJSON = encodeJSONObject(path) else { return }
        let pathsDict: [String: Any] = [
            "type": "paths",
            "to": userId,
            "payload": ["path": pathJSON]
        ]
        send(pathsDict)
    }
    
    private func encodeJSONObject<T: Encodable>(_ value: T) -> Any? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }
    
    private static func decode<T: Decodable>(_ type: T.Type, fromJSONObject object: Any?) -> T? {
        guard let object,
              JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    private func send(_ dict: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        
        print("📤 Sending: \(jsonString)")
        
        webSocket?.send(.string(jsonString)) { error in
            if let error = error {
                print("Send error: \(error)")
            } else {
                print("✅ Sent successfully")
            }
        }
    }
    
    private func listenForMessages() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📥 Received: \(text)")
                    self?.handleMessage(text)
                default:
                    break
                }
                self?.listenForMessages() // Continue listening
            case .failure(let error):
                print("Receive error: \(error)")
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return }
        
        DispatchQueue.main.async { [weak self] in
            switch type {
            case "incoming_call":
                if let from = json["from"] as? String,
                   let payload = json["payload"] as? [String: Any],
                   let sdp = payload["sdp"] as? String {
                    self?.currentCallPartner = from
                    self?.webRTCManager?.acceptCall(from: from, withOffer: sdp)
                }
                
            case "call_answered":
                if let payload = json["payload"] as? [String: Any],
                   let sdp = payload["sdp"] as? String {
                    self?.webRTCManager?.setRemoteDescription(sdp: sdp, type: .answer) {
                        print("Remote description set")
                    }
                }
                
            case "ice-candidate":
                if let payload = json["payload"] as? [String: Any],
                   let candidate = payload["candidate"] as? String,
                   let sdpMid = payload["sdpMid"] as? String,
                   let sdpMLineIndex = payload["sdpMLineIndex"] as? Int32 {
                    self?.webRTCManager?.handleICECandidate(candidate, sdpMid: sdpMid, sdpMLineIndex: sdpMLineIndex)
                }
                
            case "path":
                if let payload = json["payload"] as? [String: Any],
                   let path = Self.decode(UserPath.self, fromJSONObject: payload["path"]) {
                    self?.webRTCManager?.onDraw?(path)
                }
                
            case "success":
                print("✅ Server success: \(json["payload"] ?? "")")
                
            case "error":
                print("❌ Server error: \(json["payload"] ?? "")")
                
            default:
                print("Unknown message type: \(type)")
            }
        }
    }
    
    // URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected successfully!")
        sendRegister()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonText = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "none"
        print("❌ WebSocket disconnected: \(closeCode.rawValue) reason: \(reasonText)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("❌ WebSocket task failed: \(error.localizedDescription)")
            print("❌ Underlying: \(error)")
        }
    }
    
    // Local/dev servers often use a self-signed cert. Safari can prompt to trust it;
    // URLSession cannot, so accept the server trust for this host only.
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let space = challenge.protectionSpace
        if space.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           space.host == serverURL.host(),
           let trust = space.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }
}


