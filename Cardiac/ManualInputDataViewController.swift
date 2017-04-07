//
//  ManualInputDataViewController.swift
//  Cardiac
//
//  Created by Eileen Guo on 4/7/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import Foundation
import UIKit

class ManualInputDataViewController: UIViewController, UITextFieldDelegate {
    
    let directoryModel = DirectoryModel.sharedInstance

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
    
    @IBAction func submitTrialRound(_ sender: Any) {
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
        directoryModel.saveBodyTrialRound(manualEntryData: manualEntry, trialPosition: "sitting", trialStartTime: Date(), trailEndTime: Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
