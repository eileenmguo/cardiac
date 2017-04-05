//
//  ViewController.swift
//  Cardiac
//
//  Created by Eileen Guo on 3/20/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let directoryModel = DirectoryModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        directoryModel.startFaceSession(subjectID: 1, overwriteExistingSession: true)
        directoryModel.saveFaceTrailRound(trialPosition: "sitting", trialStartTime: Date(), trailEndTime: Date())
        directoryModel.saveFaceTrailRound(trialPosition: "standing", trialStartTime: Date(), trailEndTime: Date())
        directoryModel.finishSubjectSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

