//
//  DemSurveyViewController.swift
//  Cardiac
//
//  Created by Eileen Guo on 3/21/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import Foundation
import UIKit

class DemSurveyViewController: UIViewController {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
