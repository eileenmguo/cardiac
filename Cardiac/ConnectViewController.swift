//
//  ConnectViewController.swift
//  Cardiac
//
//  Created by Eileen Guo on 4/18/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import Foundation
import UIKit


class ConnectViewController: UIViewController {
    let directoryModel = DirectoryModel.sharedInstance
    let connectivityManager = ConnectivityManager.sharedInstance
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var connectionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectivityManager.delegate = self

    }
    
    override func  viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("CVC is disappearring")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startExperiment() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: directoryModel.phoneMode!)
        DispatchQueue.main.async {
            self.show(controller!, sender: self)
        }
    }
    
    @IBAction func onPress(_ sender: Any) {
        connectivityManager.send(message: ["action": directoryModel.START_EXP])
        startExperiment()
    }
}


extension ConnectViewController : ConnectivityManagerDelegate {
    func didReceive(message: [String:Any]) {
        print("performing an action from video")
        switch message["action"] as! String {
        case directoryModel.START_EXP:
            startExperiment()
        default:
            print("ConnectViewController was unable to parse message")
        }
    }
    
    func connectedDevicesChanged(manager: ConnectivityManager, connectedDevices: [String]) {
        DispatchQueue.main.async {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
}

