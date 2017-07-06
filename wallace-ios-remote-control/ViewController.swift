//
//  ViewController.swift
//  wallace-ios-remote-control
//
//  Created by Jonathan Böcker on 2017-07-04.
//  Copyright © 2017 Jonathan Böcker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var ConnectToIPButton: UIButton!
    @IBOutlet weak var iPadressField: UITextField!
    
    @IBOutlet weak var rightMotorSpeedSlider: UISlider!{
        didSet{
            rightMotorSpeedSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            rightMotorSpeedSlider.minimumValue = -100
            rightMotorSpeedSlider.maximumValue = 100
            rightMotorSpeedSlider.setValue(0, animated: false)
        }
    }
    
    @IBOutlet weak var leftMotorSpeedSlider: UISlider!{
        didSet{
            leftMotorSpeedSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            leftMotorSpeedSlider.minimumValue = -100
            leftMotorSpeedSlider.maximumValue = 100
            leftMotorSpeedSlider.setValue(0, animated: false)
        }
    }
    
    @IBOutlet weak var leftSpeedSliderValue: UILabel!
    @IBOutlet weak var rightSpeedSliderValue: UILabel!
    
    @IBOutlet weak var stopMotorsButton: UIButton!
    
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
    }
    
    @IBAction func leftSliderValueChanged(_ sender: UISlider) {
        leftSpeedSliderValue.text = String(Int(sender.value))
    }
    
    @IBAction func stopMotorsButtonPressed() {
        leftMotorSpeedSlider.value = 0
        leftSpeedSliderValue.text = "0"
        
        rightMotorSpeedSlider.value = 0
        rightSpeedSliderValue.text = "0"
    }
    
    @IBAction func onConnectButtonPressed() {
        print(iPadressField.text as Any)
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
