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
    let connectivityManager = ConnectivityManager()
    
    @IBOutlet weak var toggler: UISwitch!
    @IBOutlet weak var connectionsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        connectivityManager.delegate = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggle(_ sender: Any) {
        connectivityManager.send(message: ["toggler": self.toggler.isOn])
    }
}


extension ConnectViewController : ConnectivityManagerDelegate {
    func didReceive(message: [String:Any]) {
        OperationQueue.main.addOperation {
            self.toggler.isOn = (message["toggler"] != nil)
        }
    }
    
    func connectedDevicesChanged(manager: ConnectivityManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
}
