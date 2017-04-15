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
    
    
    @IBAction func submitBodyTrialRound(_ sender: Any) {
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
        let storyboard = self.storyboard
        if directoryModel.trialList.count < 4 {
            let controller = storyboard?.instantiateViewController(withIdentifier: "bodyCam")
            self.present(controller!, animated: true, completion: nil)
        } else {
            directoryModel.finishSubjectSession()
            let controller = storyboard?.instantiateViewController(withIdentifier: "home")
            self.present(controller!, animated: true, completion: nil)
        }
    }
    
    @IBAction func submitFaceTrialRound(_ sender: Any) {
        directoryModel.saveFaceTrailRound()
        let storyboard = self.storyboard
        if directoryModel.trialList.count < 4 {
            let controller = storyboard?.instantiateViewController(withIdentifier: "faceCam")
            self.present(controller!, animated: true, completion: nil)
        } else {
            directoryModel.finishSubjectSession()
            let controller = storyboard?.instantiateViewController(withIdentifier: "home")
            self.present(controller!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if directoryModel.trialList.count < 3 {
            self.roundDesc.text = directoryModel.POSITIONS[directoryModel.trialList.count] + " round is complete!"
            self.nextButton.setTitle("Next Round", for: UIControlState.normal)
        } else {
            self.roundDesc.text = "Study is complete!"
            self.nextButton.setTitle("Finish", for: UIControlState.normal)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TrialEndViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
