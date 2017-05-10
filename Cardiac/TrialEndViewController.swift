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
    let bioHarness = BioHarness.sharedInstance
    let e4 = E4Controller.sharedInstance

    let SUBMIT_RND = "submitRound"
    let RESET_RND = "resetRound"

    @IBOutlet weak var CardioBuddyBPM: UITextField!
    @IBOutlet weak var PulseOxSp02: UITextField!
    @IBOutlet weak var PulseOxBPM: UITextField!
    @IBOutlet weak var iCareBloodViscosity: UITextField!
    @IBOutlet weak var iCarePulseOx: UITextField!
    @IBOutlet weak var iCareBPM: UITextField!
    @IBOutlet weak var iCareBPSystolic: UITextField!
    @IBOutlet weak var iCareBPDiastolic: UITextField!
    @IBOutlet weak var groundTruthBPSystolic: UITextField!
    @IBOutlet weak var groundTruthBPDiastolic: UITextField!
    
    @IBAction func screenTapped(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
        allFieldsCompleted()
    }
    
    
    @IBOutlet weak var roundDesc: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    

    @IBAction func submitRound(_ sender: Any) {
        connectivityManager.send(message: ["action": SUBMIT_RND])
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submit() {
        if directoryModel.phoneMode! == directoryModel.FACE {
            directoryModel.saveFaceTrailRound()
            if directoryModel.trialList.count < 4 {
                DispatchQueue.main.async {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "faceCam")
                    self.show(controller!, sender: self)
                }
            } else {
                directoryModel.finishSubjectSession()
                DispatchQueue.main.async {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "home")
                    self.show(controller!, sender: self)
                }
            }
        } else {
            let manualEntry = [
                "cardioBuddyBPM": CardioBuddyBPM.text!,
                "pulseOx": ["sp02": PulseOxSp02.text!, "bpm": PulseOxBPM.text!],
                "bloodPressure": [
                    "systolic": groundTruthBPSystolic.text!,
                    "diastolic": groundTruthBPDiastolic.text!
                ],
                "iCare": [
                    "bloodViscosity": iCareBloodViscosity.text!,
                    "pulseOx": iCarePulseOx.text!,
                    "bpm": iCareBPM.text!,
                    "bloodPressure": [
                        "systolic": iCareBPSystolic.text!,
                        "diastolic": iCareBPDiastolic.text!
                    ],
                ]
                ]  as [String : Any]
            
            // need to update trialpostiion, startTime, endTime
            directoryModel.saveBodyTrialRound(manualEntryData: manualEntry)
            if directoryModel.trialList.count < 4 {
                DispatchQueue.main.async {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "bodyCam")
                    self.show(controller!, sender: self)
                }
            } else {
                directoryModel.finishSubjectSession()
                bioHarness.disconnect()
                e4.disconnect()
                DispatchQueue.main.async {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "home")
                    self.show(controller!, sender: self)
                }
            }
        }
    }
    
    @IBAction func resetSwipe(_ sender: Any) {
        connectivityManager.send(message: ["action": RESET_RND])
        resetRound()
    }
    
    func resetRound() {
        DispatchQueue.main.async {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: self.directoryModel.phoneMode!)
            self.show(controller!, sender: self)
        }
    }
    
    func allFieldsCompleted() {
        if (self.restorationIdentifier == "bodyCamSubmit") {
            if (CardioBuddyBPM.text!.isEmpty || PulseOxBPM.text!.isEmpty || PulseOxSp02.text!.isEmpty || groundTruthBPSystolic.text!.isEmpty || groundTruthBPDiastolic.text!.isEmpty || iCareBPM.text!.isEmpty || iCarePulseOx.text!.isEmpty || iCareBPSystolic.text!.isEmpty || iCareBPDiastolic.text!.isEmpty || iCareBloodViscosity.text!.isEmpty) {
                self.nextButton.isEnabled = false
            } else {
                self.nextButton.isEnabled = true
            }
        }
    }
}


extension TrialEndViewController : ConnectivityManagerDelegate {
    func didReceive(message: [String:Any]) {
        switch message["action"] as! String {
        case SUBMIT_RND:
            submit()
        case RESET_RND:
            resetRound()
        default:
            print("TrialEndViewController was unable to parse message")
        }
    }
    
    func connectedDevicesChanged(manager: ConnectivityManager, connectedDevices: [String]) {
        print("Connections: \(connectedDevices)")
    }
}


