//
//  ViewController.swift
//  Cardiac
//
//  Created by Eileen Guo on 3/20/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Accessing Singleton Classes
    let directoryModel = DirectoryModel.sharedInstance
    let connectivityManager = ConnectivityManager.sharedInstance
    let bioHarness = BioHarness.sharedInstance
    let e4 = E4Controller.sharedInstance
    
    // Available Actions for this view controller to send to paired iPhone
    let CHOOSE_MODE = "chooseCam"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectivityManager.delegate = self
        
        // Disconnecting all bluetooth devices
        if bioHarness.zephyrConnected {
            bioHarness.disconnect()
        }
        if e4.E4Connected {
            e4.disconnect()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Choosing camera type for both phones
    @IBAction func startFaceCam(_ sender: Any) {
        connectivityManager.send(message: ["action": CHOOSE_MODE, "phoneMode": directoryModel.BODY])
        startExperiment(phoneMode: directoryModel.FACE)
    }
    @IBAction func startBodyCam(_ sender: Any) {
        connectivityManager.send(message: ["action": CHOOSE_MODE, "phoneMode": directoryModel.FACE])
        startExperiment(phoneMode: directoryModel.BODY)
    }
    
    // Moving to next view controller
    func startExperiment(phoneMode: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: phoneMode + "Start")
        DispatchQueue.main.async {
            self.show(controller!, sender: self)
        }
    }
}

extension ViewController: ConnectivityManagerDelegate {
    
    // Parsing camera type
    func didReceive(message: [String:Any]) {
        switch message["action"] as! String {
        case CHOOSE_MODE:
            startExperiment(phoneMode: message["phoneMode"] as! String)
        default:
            print("home: unable to parse message")
        }
    }
    
    // Shows which devices are connected
    func connectedDevicesChanged(manager: ConnectivityManager, connectedDevices: [String]) {
        print("Connections: \(connectedDevices)")
    }
}

