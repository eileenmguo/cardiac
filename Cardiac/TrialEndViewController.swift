//
//  ManualInputDataViewController.swift
//  Cardiac
//
//  Created by Eileen Guo on 4/7/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import Foundation
import UIKit

class TrialEndViewController: UIViewController, UITextFieldDelegate {
    
    let directoryModel = DirectoryModel.sharedInstance
    let connectivityManager = ConnectivityManager.sharedInstance


    @IBOutlet weak var CardioBuddyBPM: UITextField!
    @IBOutlet weak var PulseOxSp02: UITextField!
    @IBOutlet weak var PulseOxBPM: UITextField!
    @IBOutlet weak var bloodPressureGT: UITextField!
    @IBOutlet weak var iCareBloodViscosity: UITextField!
    @IBOutlet weak var iCarePulseOx: UITextField!
    @IBOutlet weak var iCareBPM: UITextField!
    @IBOutlet weak var iCareBloodPressure: UITextField!
    
    @IBAction func screenTapped(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
    }
    
    
    @IBOutlet weak var roundDesc: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    

    @IBAction func submitRound(_ sender: Any) {
        submit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectivityManager.delegate = self
        
        if directoryModel.trialList.count < 3 {
            self.roundDesc.text = directoryModel.POSITIONS[directoryModel.trialList.count] + " round is complete!"
            self.nextButton.setTitle("Next Round", for: UIControlState.normal)
        } else {
            self.roundDesc.text = "Study is complete!"
            self.nextButton.setTitle("Finish", for: UIControlState.normal)
        }
    }
    
    func submit() {
        if directoryModel.phoneMode! == directoryModel.FACE {
            directoryModel.saveFaceTrailRound()
            if directoryModel.trialList.count < 4 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "faceCam")
                self.show(controller!, sender: self)
            } else {
                directoryModel.finishSubjectSession()
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "home")
                self.show(controller!, sender: self)
            }
        } else {
            let manualEntry = [
                "cardioBuddyBPM": CardioBuddyBPM.text!,
                "pulseOx": ["sp02": PulseOxSp02.text!, "bpm": PulseOxBPM.text!],
                "bloodPressure": bloodPressureGT.text!,
                "iCare": [
                    "bloodViscosity": iCareBloodViscosity.text!,
                    "pulseOx": iCarePulseOx.text!,
                    "bpm": iCareBPM.text!,
                    "bloodPressure": iCareBloodPressure.text!
                ]
                ]  as [String : Any]
            
            // need to update trialpostiion, startTime, endTime
            directoryModel.saveBodyTrialRound(manualEntryData: manualEntry)
            if directoryModel.trialList.count < 4 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "bodyCam")
                self.show(controller!, sender: self)
            } else {
                directoryModel.finishSubjectSession()
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "home")
                self.show(controller!, sender: self)
            }
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension TrialEndViewController : ConnectivityManagerDelegate {
    func didReceive(message: [String:Any]) {
        switch message["action"] as! String {
        case directoryModel.SUBMIT_RND:
            submit()
        case directoryModel.RESET_RND:
            print("Trial End eventually implement reset round")
        //reset round
        default:
            print("TrialEndViewController was unable to parse message")
        }
    }
    
    func connectedDevicesChanged(manager: ConnectivityManager, connectedDevices: [String]) {
        print("Connections: \(connectedDevices)")
    }
}


