//
//  DemSurveyViewController.swift
//  Cardiac
//
//  Created by Eileen Guo on 3/21/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import Foundation
import UIKit

class DemSurveyViewController: UIViewController, UITextFieldDelegate {
    
    let directoryModel = DirectoryModel.sharedInstance
    
    @IBOutlet weak var StudyID: UITextField!
    @IBOutlet weak var Gender: UISegmentedControl!
    @IBOutlet weak var Age: UITextField!
    @IBOutlet weak var HeightFt: UITextField!
    @IBOutlet weak var HeightIn: UITextField!
    @IBOutlet weak var Weight: UITextField!
    @IBOutlet weak var DominantSide: UISegmentedControl!
    @IBOutlet weak var HeartCondition: UISwitch!
    @IBOutlet weak var LungCondition: UISwitch!
    @IBOutlet weak var Medication: UISwitch!
    @IBOutlet weak var Activity: UISegmentedControl!
    
    @IBOutlet weak var Bicycle: UISwitch!
    @IBOutlet weak var Calisthenics: UISwitch!
    @IBOutlet weak var Jog: UISwitch!
    @IBOutlet weak var LiftWeigts: UISwitch!
    @IBOutlet weak var Swim: UISwitch!
    @IBOutlet weak var Walk: UISwitch!
    @IBOutlet weak var OtherExercise: UISwitch!
    @IBOutlet weak var OtherExerciseDescription: UITextField!
    
    
    @IBOutlet weak var Ethnicity: UISegmentedControl!
    
    @IBOutlet weak var Black: UISwitch!
    @IBOutlet weak var AmericanIndian: UISwitch!
    @IBOutlet weak var NativeHawaiian: UISwitch!
    @IBOutlet weak var White: UISwitch!
    @IBOutlet weak var Asian: UISwitch!
    @IBOutlet weak var OtherRace: UISwitch!
    @IBOutlet weak var OtherRaceDescription: UITextField!
    
    @IBOutlet weak var Smoke: UISegmentedControl!
    @IBOutlet weak var Alcohol: UISegmentedControl!
    
    @IBAction func screenTapped(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitSurvey(_ sender: Any) {
        let exercizes = ["bicycle": Bicycle.isOn, "calisthenics": Calisthenics.isOn, "jog": Jog.isOn, "liftWeights": LiftWeigts.isOn, "swim": Swim.isOn, "walk": Walk.isOn, "otherExercise": OtherExercise.isOn, "otherExerciseDescription": OtherExerciseDescription.text!] as [String : Any]
        let race = ["black": Black.isOn, "americanIndian": AmericanIndian.isOn, "nativeHawaiian": NativeHawaiian.isOn, "white": White.isOn, "asian": Asian.isOn, "otherRace": OtherRace.isOn, "otherRaceDescription": OtherRaceDescription.text!] as [String : Any]
        let demographicData = [
            "subjectID": StudyID.text!,
            "gender": Gender.titleForSegment(at: Gender.selectedSegmentIndex)!,
            "age": Age.text!,
            "height": HeightFt.text! + " ft " + HeightIn.text! + " in",
            "weight": Weight.text!,
            "dominantSide": DominantSide.titleForSegment(at: DominantSide.selectedSegmentIndex)!,
            "heartCondition": HeartCondition.isOn,
            "lungCondition": LungCondition.isOn,
            "medication": Medication.isOn,
            "activityAmount": Activity.titleForSegment(at: Activity.selectedSegmentIndex)!,
            "activities": exercizes,
            "ethnicity": Ethnicity.titleForSegment(at: Ethnicity.selectedSegmentIndex)!,
            "race": race,
            "smoking": Smoke.titleForSegment(at: Smoke.selectedSegmentIndex)!,
            "alcoholConsumption": Alcohol.titleForSegment(at: Alcohol.selectedSegmentIndex)!
        ] as [String : Any]
        print(demographicData)
        let failed = directoryModel.startBodySession(demographicData: demographicData)
        if failed != nil {
            print(failed!.error)
        }
    }
    
}
