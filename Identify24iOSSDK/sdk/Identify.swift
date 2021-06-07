//
//  Identify.swift
//  identSDK
//
//  Created by Emir on 6.08.2020.
//  Copyright © 2020 Emir Beytekin. All rights reserved.
//

import UIKit
import Alamofire
import Starscream
import WebRTC
//import NFCPassportReader
//import QKMRZParser
import CoreNFC
import Speech

public class IdentifyManager: WebSocketDelegate, WebRTCClientDelegate, CameraSessionDelegate {
    
    // settings for first launch
    public var userToken = ""
    public var baseAPIUrl = ""
    public var stunServers = [""]
    public var stunUsername = ""
    public var stunPassword = ""
    public var webSocketUrl = "wss://ws.identifytr.com:8888/"
    
    public var socket: WebSocket!
    public static let shared = IdentifyManager()
    public var netw = SDKNetwork()
    var tempResp: RoomResponse = RoomResponse()
    public weak var delegate: IdentifyListenerDelegate?
    public weak var appListenerDelegate: IdentifyManagerListener?
    public var loadingDelegate: LoadingViewDelegate?
    public var torchOn = false
    public var isFront = true
    public var webRTCClient: WebRTCClient!
    public var tryToConnectWebSocket: Timer?
    var cameraSession: CameraSession?
    public var userId = ""
    public var isConnected = false
    public var tid = 0
    public var nfcEnabled = false
    let languageManager = SDKLanguageManager.shared
    
    public var selectedSdkType: SDKType?
    public var identfiyModules = [Modules]()
    public var selfieType: SelfieTypes?
    public var selectedHost: HostType?

    private init() {
        self.microphoneReq()
        self.wantCameraRequest()
        self.speechReq()
        setupSettings()
    }
    
    public func addModules(module: [SdkModules]) {
        identfiyModules.removeAll()
        for modules in module {
            let module = Modules()
            module.mName = modules.rawValue
            module.mValue = modules
            identfiyModules.append(module)
        }
    }
    
    public func allModules() {
        identfiyModules.removeAll()
        let module2 = Modules()
        module2.mName = "Mrz & Nfc Screen"
        module2.mValue = .nfc
        identfiyModules.append(module2)
        
        let module3 = Modules()
        module3.mName = "Liveness Detection"
        module3.mValue = .livenessDetection
        identfiyModules.append(module3)
        
        let module5 = Modules()
        module5.mName = "Selfie"
        module5.mValue = .selfie
        identfiyModules.append(module5)
        
        let module6 = Modules()
        module6.mName = "Video Recorder"
        module6.mValue = .videoRecord
        identfiyModules.append(module6)
        
        let module7 = Modules()
        module7.mName = "Id Card"
        module7.mValue = .idCard
        identfiyModules.append(module7)
        
        let module8 = Modules()
        module8.mName = "Signature"
        module8.mValue = .signature
        identfiyModules.append(module8)
        
        let module9 = Modules()
        module9.mName = "Speech Recognition"
        module9.mValue = .speech
        identfiyModules.append(module9)
    }
    
    public func openWaitScreen() {
//        let controller = SDKCallWaitScreenController.instantiate()
//        if #available(iOS 13.0, *) {
//            controller.isModalInPresentation = true
//        }
//        controller.manager = self
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if #available(iOS 13, *) {
//                UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: false, completion: nil)
//            } else {
//                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(controller, animated: false, completion: nil)
//            }
//        }
    }

    public func setupUrls() {
        switch selectedHost {
        case .identifyTr:
//            self.baseAPIUrl = URLConstants.baseAPIUrl
//            self.stunServers = URLConstants.stunServers
//            self.stunUsername = URLConstants.stunUsername
//            self.stunPassword = URLConstants.stunPassword
            self.socket = WebSocket(url: URL(string: self.webSocketUrl)!)
            self.setupSettings()
        case .kimlikBasit:
            self.baseAPIUrl = KBURLConstants.baseAPIUrl
            self.stunServers = KBURLConstants.stunServers
            self.stunUsername = KBURLConstants.stunUsername
            self.stunPassword = KBURLConstants.stunPassword
            self.socket = WebSocket(url: URL(string: "wss://ws.kimlikbasit.com:8888")!)
            self.setupSettings()
        default:
            return
        }
    }
    
    private func setupSettings() {
        netw.BASE_URL = self.baseAPIUrl
    }
    
    public func remoteCam() -> UIView {
        let remoteVideoView = self.webRTCClient.remoteVideoView()
        self.webRTCClient.setupRemoteViewFrame(frame: CGRect(x: 0, y: 0, width: 125, height:165))
        return remoteVideoView
    }
    
    public func myCam() -> UIView {
        let myCam = self.webRTCClient.localVideoView()
        return myCam
    }
    
    public func connectToRoom() {
        netw.connectToRoom(identId: self.userToken) { res in
            if res.result == true {
                self.tempResp = res
                self.connectToWebSocket()
            }
        }
    }
    
    public func connectToWebSocket() {
        let c = self.connectToSocket()
        if c == true {
            self.loadingDelegate?.hideAllLoaders()
            self.sendFirstSubscribe(socket: self.socket)
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("UserLoggedIn"), object: nil)
        }
    }
    
    public func connectToServer() -> Bool {
        var hasSuccess = false
        netw.connectToRoom(identId: self.userToken) { resp in
            self.tempResp = resp
            if resp.result == true {
                let c = self.connectToSocket()
                if c == true {
                    self.loadingDelegate?.hideAllLoaders()
                    self.sendFirstSubscribe(socket: self.socket)
                    self.openWaitScreen()
                }
            } else {
                self.loadingDelegate?.hideAllLoaders()
            }
            hasSuccess = resp.result ?? false
        }
        return hasSuccess
    }
    
    public func sendSmsTan(tan:String) {
        netw.verifySms(tid: "\(tid)", tan: tan) { resp in
            self.sendSmsStatus(tanCode: tan)
            self.delegate?.approvedSms(stats: resp.result ?? false)
        }
    }
    
    public func connectWithRoomId(roomId: String)  {
        self.netw.connectToRoom(identId: roomId) { (resp) in
            self.tempResp = resp
        }
    }
    
    func getStats() -> RoomResponse {
        let _ = self.connectToServer()
        if self.tempResp.data?.customer_id != "" {
            let _ = self.connectToSocket()
        }
        return self.tempResp
    }
    
    public func connectToSocket() -> Bool {
        socket.delegate = self
        socket.pongDelegate = self as? WebSocketPongDelegate
        self.socket.enableCompression = true
        self.socket.desiredTrustHostname = "identify24"
        self.socket.disableSSLCertValidation = true
        socket.connect()
        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
        webRTCClient.setup(videoTrack: true, audioTrack: true, dataChannel: true, customFrameCapturer: false, isFront: true)
        isConnected = true
        tryToConnectWebSocket = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.webRTCClient.isConnected || self.socket.isConnected {
                self.socket.enableCompression = true
                self.socket.desiredTrustHostname = "identify24"
                self.socket.disableSSLCertValidation = true
                return
            }
        })
//        socket.onDisconnect = { [weak self] error in
//            self?.loadingDelegate?.hideAllLoaders()
//            AlertViewManager.defaultManager.showOkAlert("Kimlik Basit", message: "Bağlantı sona erdi") { (action) in
//                self?.dismissAllPresents()
//            }
//        }
        return true
    }
    
    public func dismissAllPresents() {
        if #available(iOS 13, *) {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        } else {
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func translate(text: Keywords) -> String {
        return languageManager.translate(key: text)
    }
    
    public func sendCurrentScreen(screen: SdkModules) {
        let newSignal = ConnectSocketResp.init(location: screen.rawValue, room: tempResp.data?.customer_uid ?? "", action: "stepChanged")
        do {
            let data = try JSONEncoder().encode(newSignal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
            
        } catch {
            // print(error)
        }
        
    }
    
    public func sendImOnline(socket: WebSocketClient) {
        let newSignal2 = ConnectSocketResp.init(location: "conf", room: tempResp.data?.customer_uid ?? "", action: "imOnline")
        do {
            let data = try JSONEncoder().encode(newSignal2)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
            
        } catch {
            // print(error)
        }
    }
    
    public func sendSmsStatus(tanCode: String) {
        let signal = sendSmsStr.init(action: "tan_entered", room: tempResp.data?.customer_uid ?? "", tid: "\(self.tid)", tan: tanCode)
        do {
            let data = try JSONEncoder().encode(signal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            // print(error.localizedDescription)
        }
    }
    
    public func sendFirstSubscribe(socket: WebSocketClient) {
        
        if tempResp.data?.customer_uid == "" {
            AlertViewManager.defaultManager.showOkAlert(self.translate(text: .coreError), message: "Customer ID alınamadı, lütfen bağlantınızı kontrol edin") { _ in }
        } else {
            // print("### first subscribe gönderildi \(tempResp.data?.customer_uid ?? "") ###")
            let newSignal = ConnectSocketResp.init(location: "NFCCheck", room: tempResp.data?.customer_uid ?? "", action: "subscribe")
            do {
                let data = try JSONEncoder().encode(newSignal)
                let message = String(data: data, encoding: String.Encoding.utf8)!
                if self.socket.isConnected {
                    self.socket.write(string: message)
                }
            } catch {
                AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
            }
        }
        
    }
    
    public func sendNFCStatus(_ isAvailable: Bool) {
        let deviceHardwareCheck = NFCReaderSession.readingAvailable
        if !deviceHardwareCheck {
            let newSignal = NFCConnectSocketResp.init(room: tempResp.data?.customer_uid ?? "", action: "NFCStatus", status: "notAvailable")
            do {
                let data = try JSONEncoder().encode(newSignal)
                let message = String(data: data, encoding: String.Encoding.utf8)!
                if self.socket.isConnected {
                    self.socket.write(string: message)
                }
            } catch {
                AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
            }
        } else {
            let nfcStatus = isAvailable ? "true" : "false"
            let newSignal = NFCConnectSocketResp.init(room: tempResp.data?.customer_uid ?? "", action: "NFCStatus", status: nfcStatus)
            do {
                let data = try JSONEncoder().encode(newSignal)
                let message = String(data: data, encoding: String.Encoding.utf8)!
                if self.socket.isConnected {
                    self.socket.write(string: message)
                }
            } catch {
                AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
            }
        }
    }
    
    public func sendSelfieImageStatus(uploadStatus: String, actionName: String) {
        let newStats:Bool? = uploadStatus == "true" ? true : false
        let newSignal = ToogleCamera.init(action: actionName, result:newStats ?? false, room: tempResp.data?.customer_uid ?? "")
        do {
            let data = try JSONEncoder().encode(newSignal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    /// socket functions
    
    public func websocketDidConnect(socket: WebSocketClient) {
//        self.sendFirstSubscribe(socket: self.socket!)
    }
        
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        isConnected = false
        if let error = error as? WSError {
            // print(error)
        }
        // may be self.rejectCall()
//        AlertViewManager.defaultManager.showOkAlert("Socket Disconnected", message: error?.localizedDescription, handler: nil)

    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        do {
            let signalingMessage = try JSONDecoder().decode(SendCandidate.self, from: text.data(using: .utf8)!)
            let cominCan = try JSONDecoder().decode(GetCandidate.self, from: text.data(using: .utf8)!)
            let smsCan = try JSONDecoder().decode(SMSCandidate.self, from: text.data(using: .utf8)!)
            if cominCan.action == "candidate" {
                let x = signalingMessage.candidate!
                let can = RTCIceCandidate(sdp: x.candidate, sdpMLineIndex: x.sdpMLineIndex, sdpMid: x.sdpMid)
                webRTCClient.receiveCandidate(candidate: can)
            }
//            // print("##### gelen socket mesajı::::: \(signalingMessage.action) #####")
            if signalingMessage.action == "initCall" {
                delegate?.incomingCall()
                appListenerDelegate?.sdkResponse(stats: IdentifyListener.init(status: true, message: "initCall"))
            } else if signalingMessage.action == "newSub" {
                sendImOnline(socket: self.socket!)
            } else if signalingMessage.action == "imOnline" {
                sendImOnline(socket: self.socket!)
            } else if signalingMessage.action == "startCall" {
                
            } else if signalingMessage.action == "endCall" {
                delegate?.endCall()
            } else if signalingMessage.action == "terminateCall" {
                delegate?.terminateCall()
            } else if signalingMessage.action == "imOffline" {
                delegate?.imOffline()
            } else if signalingMessage.action == "requestTan" {
                self.tid = smsCan.tid ?? 0
                delegate?.comingSms()
            } else if signalingMessage.action == "sdp" {
                let sm = try JSONDecoder().decode(SDPSender.self, from: text.data(using: .utf8)!)
                webRTCClient.receiveAnswer(answerSDP: RTCSessionDescription(type: .answer, sdp: sm.sdp!.sdp))
            }
            else if signalingMessage.action == "toggleFlash" {
                torchOn = !torchOn
                if !isFront {
                    self.sendTorchPositionSocket(isOpened: torchOn)
                    self.toggleTorch(on: torchOn)
                }
            } else if signalingMessage.action == "toggleCamera" {
                self.isFront = !isFront
                self.sendCameraPositionSocket(isFront: isFront)
                webRTCClient.switchCameraPosition()
            } else if signalingMessage.action == "faceGuideOn" {
                self.sendFaceGuideInfoSocket(isOpened: true)
                delegate?.openWarningCircle()
            } else if signalingMessage.action == "faceGuideOff" {
                self.sendFaceGuideInfoSocket(isOpened: false)
                delegate?.closeWarningCircle()
            } else if signalingMessage.action == "skipNFC" {
                delegate?.skipNFC()
            } else if signalingMessage.action == "idGuideOn" {
                self.sendCardGuideInfoSocket(isOpened: true)
                delegate?.openCardCircle()
            } else if signalingMessage.action == "idGuideOff" {
                self.sendCardGuideInfoSocket(isOpened: false)
                delegate?.closeCardCircle()
            } else if signalingMessage.action == "subRejected" {
                AlertViewManager.defaultManager.showOkAlert(self.translate(text: .coreError), message: "Belirtilen bağlantı sayısı aşıldı") { _ in
                    self.loadingDelegate?.hideAllLoaders()
                    self.dismissAllPresents()
                }
            }
            //subRejected
        } catch {
            // print(error)
        }
    }
    
    public func sendTorchPositionSocket(isOpened: Bool) {
        let signal = ToogleTorch.init(action: "toggleFlash",result:isOpened, room: tempResp.data?.customer_uid ?? "")
        do {
            let data = try JSONEncoder().encode(signal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    public func sendCameraPositionSocket(isFront: Bool) {
        let signal = ToogleCamera.init(action: "toggleCamera", result:isFront, room: tempResp.data?.customer_uid ?? "")
        do {
            let data = try JSONEncoder().encode(signal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    public func sendFaceGuideInfoSocket(isOpened: Bool) {
        let signal = ToogleCamera.init(action: "faceGuide", result:isOpened, room: tempResp.data?.customer_uid ?? "")
        do {
            let data = try JSONEncoder().encode(signal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    public func sendCardGuideInfoSocket(isOpened: Bool) {
        let signal = ToogleCamera.init(action: "idGuide", result:isOpened, room: tempResp.data?.customer_uid ?? "")
        do {
            let data = try JSONEncoder().encode(signal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    public func sendLiveStatus() {
        let signal = ToogleTorch.init(action: "isSmiling",result: true, room: tempResp.data?.customer_uid ?? "")
        do {
            let data = try JSONEncoder().encode(signal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
    
    public func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        self.sendCandidate(iceCandidate: iceCandidate)
    }
    
    public func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState) { }
    
    public func didOpenDataChannel() {
        // print("did open data channel")
    }
    
    public func didReceiveData(data: Data) { }
    
    public func didReceiveMessage(message: String) { }
    
    public func didConnectWebRTC() {
        self.webRTCClient.speakerOn()
    }
    
    public func didDisconnectWebRTC() {
        rejectCall()
    }
    
    public func didOutput(_ sampleBuffer: CMSampleBuffer) { }
    
    public func acceptCall() {
        webRTCClient.connect { (desc) in
            let msg = CallSocketResp(action: "startCall", room: self.tempResp.data?.customer_uid ?? "")
            do {
                let data = try JSONEncoder().encode(msg)
                let message = String(data: data, encoding: String.Encoding.utf8)!
                if self.socket.isConnected {
                    self.socket.write(string: message)
                    self.sendSDP(sessionDescription: RTCSessionDescription(type: .offer, sdp: desc.sdp))
                }
            } catch {
                AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
            }
        }
    }
    
    public func rejectCall() {
        self.socket.disconnect()
        self.webRTCClient.disconnect()
    }
    
    public func sendSDP(sessionDescription: RTCSessionDescription) {
        let sdpp = SDP2.init(type: "offer", sdp: sessionDescription.sdp)
        let sm2 = SDPSender.init(action: "sdp", room: self.tempResp.data?.customer_uid ?? "", sdp: sdpp)
        do {
            let data = try JSONEncoder().encode(sm2)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    public func sendCandidate(iceCandidate: RTCIceCandidate){
        let candidate = Candidate.init(candidate: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid == "audio" ? "audio" : "video")
        let newSignal = SendCandidate.init(action: "candidate", candidate: candidate, room: self.tempResp.data?.customer_uid ?? "", sessionDescription: nil)
        do {
            let data = try JSONEncoder().encode(newSignal)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        } catch {
            AlertViewManager.defaultManager.showOkAlert("Socket ERROR", message: error.localizedDescription, handler: nil)
        }
    }
    
    public func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                // print("Torch could not be used")
            }
        } else {
            // print("Torch is not available")
        }
    }
    
    public func speechReq() {
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .notDetermined:  print("Not determined")
            case .restricted:  print("Restricted")
            case .denied:  print("Denied")
            case .authorized:  print("")
            @unknown default:  print("Unknown case")
          }
        }
    }
    
    public func microphoneReq() {
        var microphoneAccessGranted = false
        let microPhoneStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        
        switch microPhoneStatus {
        case .authorized:
            microphoneAccessGranted = true
        case .denied, .restricted, .notDetermined:
            microphoneAccessGranted = false
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (alowedAccess) -> Void in
                if !alowedAccess {
//                    weakSelf?.showMicrophonePermisionPopUp()
                }
            })
        }
    }
        
    public func wantCameraRequest() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        let userAgreedToUseIt = authorizationStatus == .authorized
        if userAgreedToUseIt {
           
            //Do whatever you want to do with camera.
            
        } else if authorizationStatus == .denied
            || authorizationStatus == .restricted
            || authorizationStatus == .notDetermined {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (alowedAccess) -> Void in
                if alowedAccess {
                    self.microphoneReq()
                } else {
                    self.microphoneReq()
                }
            })
        }
    }

}

extension UIImage {
    
    public func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}

extension Encodable {
    
    public func asDictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                // print("Request Object dictionary ' e çevrilirken hata oluştu.")
                return [:]
            }
            return dictionary
            
        } catch {
            // print("AsDictionary hatası :  \(error)")
            return [:]
        }
    }
}

extension UIViewController {
    
    public static func instantiate() -> Self {
        func instanceFromNib<T: UIViewController>() -> T {
            return T(nibName: String(describing: self), bundle: Bundle(for: self))
        }
        return instanceFromNib()
    }
}

extension UIStoryboard {
    
    public func instantiateSB<T>() -> T {
        
            return instantiateViewController(withIdentifier: String(describing: T.self)) as! T
        }

        static let main = UIStoryboard(name: "KYC", bundle: nil)

}
