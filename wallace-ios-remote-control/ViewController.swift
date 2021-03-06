//
//  ViewController.swift
//  wallace-ios-remote-control
//
//  Created by Jonathan Böcker on 2017-07-04.
//  Copyright © 2017 Jonathan Böcker. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController, WebSocketDelegate {
    
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ConnectToIPButton: UIButton!
    @IBOutlet weak var iPadressField: UITextField!
    
    @IBOutlet weak var rightMotorSpeedSlider: UISlider!{
        didSet{
            initSlider(slider: rightMotorSpeedSlider)
            rightMotorSpeedSlider.isEnabled = false
        }
    }
    
    @IBOutlet weak var leftMotorSpeedSlider: UISlider!{
        didSet{
            initSlider(slider: leftMotorSpeedSlider)
            leftMotorSpeedSlider.isEnabled = false
        }
    }
    
    @IBOutlet weak var leftSpeedSliderValue: UILabel!
    @IBOutlet weak var rightSpeedSliderValue: UILabel!
    
    @IBOutlet weak var stopMotorsButton: UIButton!{
        didSet{
            stopMotorsButton.isEnabled = false
        }
    }
    
    var socket: WebSocket?
    var oldSliderValues = (0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(_ _: UISlider) {
        let newSliderValues = getSliderValues()
        if newSliderValues != oldSliderValues {
            oldSliderValues = newSliderValues
            let (right, left) = newSliderValues
            rightSpeedSliderValue.text = String(right)
            leftSpeedSliderValue.text = String(left)
            sendMotorSpeedsToRobot(rightMotor: right, leftMotor: left)
        }
    }
    
    
    @IBAction func stopMotorsButtonPressed() {
        leftMotorSpeedSlider.value = 0
        leftSpeedSliderValue.text = "0"
        
        rightMotorSpeedSlider.value = 0
        rightSpeedSliderValue.text = "0"
        sendMotorSpeedsToRobot(rightMotor: 0, leftMotor: 0)
    }
    
    @IBAction func onConnectButtonPressed() {
        
        if validateIpAddress(ipToValidate: iPadressField.text!) {
            socket?.disconnect()
            
            connectingIndicator.startAnimating()
            ConnectToIPButton.isHidden = true
            
            socket = WebSocket(url: URL(string: "ws://\(iPadressField.text!):8887/")!)
            socket?.delegate = self
            socket?.connect()
        } else {
            print("Not a valid IP Address!")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        self.connectingIndicator.stopAnimating()
        
        self.ConnectToIPButton.isHidden = false
        self.ConnectToIPButton.isEnabled = true
        
        rightMotorSpeedSlider.value = 0
        rightMotorSpeedSlider.isEnabled = false
        
        leftMotorSpeedSlider.value = 0
        leftMotorSpeedSlider.isEnabled = false
        
        stopMotorsButton.isEnabled = false
        
        print("websocket is disconnected: \(error?.localizedDescription ?? "no error")")
    }
    
    func websocketDidConnect(socket: WebSocket) {
        connectingIndicator.stopAnimating()
        
        ConnectToIPButton.isHidden = false
        ConnectToIPButton.isEnabled = false
        
        rightMotorSpeedSlider.value = 0
        rightMotorSpeedSlider.isEnabled = true
        
        leftMotorSpeedSlider.value = 0
        leftMotorSpeedSlider.isEnabled = true
        
        stopMotorsButton.isEnabled = true
        
        print("websocket is connected")
    }
    
    func sendMotorSpeedsToRobot(rightMotor: Int, leftMotor: Int) {
        if (socket?.isConnected) ?? false {
            let message = "motor: left \(leftMotor) right \(rightMotor)"
            print("SENDING: \(message)")
            socket?.write(string: message)
        }
    }
    
    func initSlider(slider: UISlider) {
        slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        slider.minimumValue = -255
        slider.maximumValue = 255
        slider.setValue(0, animated: false)
    }
    
    func validateIpAddress(ipToValidate: String) -> Bool {
        var sin = sockaddr_in()
        
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return true
        }
        
        return false
    }
    
    func getSliderValues() -> (Int, Int) {
        return (Int(rightMotorSpeedSlider.value), Int(leftMotorSpeedSlider.value))
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
