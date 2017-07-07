//
//  ViewController.swift
//  wallace-ios-remote-control
//
//  Created by Jonathan Böcker on 2017-07-04.
//  Copyright © 2017 Jonathan Böcker. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController {
    
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ConnectToIPButton: UIButton!
    @IBOutlet weak var iPadressField: UITextField!
    
    @IBOutlet weak var rightMotorSpeedSlider: UISlider!{
        didSet{
            initSlider(slider: rightMotorSpeedSlider)
        }
    }
    
    @IBOutlet weak var leftMotorSpeedSlider: UISlider!{
        didSet{
            initSlider(slider: leftMotorSpeedSlider)
        }
    }
    
    @IBOutlet weak var leftSpeedSliderValue: UILabel!
    @IBOutlet weak var rightSpeedSliderValue: UILabel!
    
    @IBOutlet weak var stopMotorsButton: UIButton!
    
    var socket: WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rightSliderValueChanged(_ sender: UISlider) {
        rightSpeedSliderValue.text = String(Int(sender.value))
        sendMotorSpeedsToRobot(rightMotor: Int(sender.value), leftMotor: Int(leftMotorSpeedSlider.value))
    }
    
    @IBAction func leftSliderValueChanged(_ sender: UISlider) {
        leftSpeedSliderValue.text = String(Int(sender.value))
        sendMotorSpeedsToRobot(rightMotor: Int(rightMotorSpeedSlider.value), leftMotor: Int(sender.value))
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
            
            socket?.onConnect = {
                self.connectingIndicator.stopAnimating()
                self.ConnectToIPButton.isHidden = false
                self.ConnectToIPButton.isEnabled = false
                print("websocket is connected")
            }
            
            socket?.onDisconnect = { (error: NSError?) in
                self.connectingIndicator.stopAnimating()
                self.ConnectToIPButton.isHidden = false
                self.ConnectToIPButton.isEnabled = true
                print("websocket is disconnected: \(error?.localizedDescription ?? "no error")")
            }
            
            socket?.onText = { (text: String) in
                print("got some text: \(text)")
            }
            
            socket?.onData = { (data: Data) in
                print("got some data: \(data.count)")
            }
            
            socket?.connect()
        } else {
            print("Not a valid IP Address!")
        }
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
        slider.minimumValue = -100
        slider.maximumValue = 100
        slider.setValue(0, animated: false)
    }
    
    func validateIpAddress(ipToValidate: String) -> Bool {
        var sin = sockaddr_in()
        
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return true
        }
        
        return false
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
