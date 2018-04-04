//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import Foundation

/// The option to add a \n or \r or \r\n to the end of the send message

enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}
 

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {
//IBOutlets
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var Forward: UIButton!
    @IBOutlet weak var Left: UIButton!
    @IBOutlet weak var Right: UIButton!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var speed: UILabel!
    
    

//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init serial
        serial = BluetoothSerial(delegate: self)
        reloadView()
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }


//BluetoothSerialDelegate
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
//IBActions

    @IBAction func barButtonPressed(_ sender: AnyObject) {
        serial.disconnect()
        performSegue(withIdentifier: "ShowScanner", sender: self)
        reloadView()
    }
    
    @IBAction func controllButtonPressed(_ sender: UIButton) {
        let selectedButton = sender
        var msg: String
        let button = (selectedButton as UIButton).titleLabel?.text
        
        if !serial.isReady {
            let alertController = UIAlertController(title: "not connected", message: "check bluetooth connection", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        switch button {
            case "Forward"?:
                msg = "F"
                serial.sendMessageToDevice(msg)
            
            case "Left"?:
                msg = "L"
                serial.sendMessageToDevice(msg)
            
            case "Right"?:
                msg = "R"
                serial.sendMessageToDevice(msg)
            
            case "Back"?:
                msg = "B"
                serial.sendMessageToDevice(msg)
            
            case "Stop"?:
                msg = "0"
                serial.sendMessageToDevice(msg)

            default: break
        }
    }
    
    @IBAction
    func sliderUpdate(){
        speed.text = slider.value.description
        var float: Float
        var int: Int
        var msg: String
        float =  Float(slider.value.description)!
        int = Int(float)
        msg = String(int)
        print("The speed is: \(msg)")
        serial.sendMessageToDevice(msg)
    }
    
}
