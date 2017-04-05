//
//  DirectoryModel.swift
//  Cardiac
//
//  Created by Eileen Guo on 3/29/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import UIKit

class DirectoryModel {
    let FACE = "faceCam"
    let BODY = "bodyCam"
    
    static let sharedInstance = DirectoryModel()
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let rootDirectoryURL:URL
    
    var subjectDirectoryURL: URL?
    
    var subjectData = [String: Any]()
    var trialList = [[String: Any]]()
    
    init() {
        self.rootDirectoryURL = URL.init(fileURLWithPath: "cardiacData", relativeTo: documentsURL)
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            if directoryContents.count == 0 {
                try FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: false, attributes: nil)
                
            //TEMP
            } else {
                try FileManager.default.removeItem(at: rootDirectoryURL)
                try FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // starts when demographic data is submitted
    func startBodySession(demographicData: [String:Any], overwriteExistingSession overwrite: Bool = false) -> (success: Bool, error: String)? {
        self.subjectData["phoneMode"] = BODY
        self.subjectData["subjectID"] = demographicData["subjectID"] as! Int?
        self.subjectData["demographicData"] = demographicData
        return createSubjectDirectory(directoryName: String(describing: subjectData["subjectID"]!) + String(describing:subjectData["phoneMode"]!), overwriteExistingSession: overwrite)
    }
    
    //Starts when subjectID is submitted
    func startFaceSession(subjectID: Int, overwriteExistingSession overwrite: Bool = false) ->
        (success: Bool, error: String)? {
        self.subjectData["phoneMode"] = FACE
        self.subjectData["subjectID"] = subjectID
        return createSubjectDirectory(directoryName: String(describing: subjectData["subjectID"]!) + String(describing: subjectData["phoneMode"]!), overwriteExistingSession: overwrite)
    }
    
    //Creates subject's root directory (can overwrite previously created directories)
    func createSubjectDirectory(directoryName: String, overwriteExistingSession overwrite: Bool = false)
        -> (success: Bool, error: String)? {
            print(directoryName)
            let newURL = URL.init(fileURLWithPath: directoryName, relativeTo: rootDirectoryURL)
            let subjectAlreadyExists = FileManager.default.fileExists(atPath: newURL.path)
            do {
                if subjectAlreadyExists {
                    if overwrite {
                        try FileManager.default.removeItem(at: newURL)
                    } else {
                        
                        print("SubjectID has already been used. Authorize to overwrite it")
                        
                        return (false, "SubjectID has already been used. Authorize to overwrite it")
                    }
                }
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
                return (false, "Error creating/deleting directory")
            }
            
            self.subjectDirectoryURL = URL.init(fileURLWithPath: newURL.path)
            
//            //debugging stuff
//            let directoryCreated = FileManager.default.fileExists(atPath: (newURL.path))
//            print("Directory: \(subjectDirectoryURL) was created: \(directoryCreated)")
            
            return nil
    }
    
    // Saving data from each round (sevens, sitting, standing, etc.) to the trial list
    func saveFaceTrailRound(trialPosition type: String, trialStartTime startTime: Date, trailEndTime endTime: Date) {
        let tempDictionary = ["startTime": startTime.description, "endTime": endTime.description, "type": type, "faceCamFilePath": "TBD", "ECGFilePath": "FILED", "bioGeneralFilePath": "stuff"] as [String : Any]
        self.trialList.append(tempDictionary)
    }
    func saveBodyTrialRound(manualEntryData manualData: [String:Any], trialPosition type: String, trialStartTime startTime: Date, trailEndTime endTime: Date) {
        let tempDictionary = ["startTime": startTime.description, "endTime": endTime.description, "type": type, "bodyCamFilePath": "TBD", "E4Filepath": "filePath of e4", "manualEntry": manualData] as [String : Any]
        self.trialList.append(tempDictionary)
    }
    
    //Saving Subject's MetadataFile
    func finishSubjectSession() {
        subjectData["trailList"] = trialList
        let filePath = URL.init(fileURLWithPath: "metaData.json", relativeTo: subjectDirectoryURL)
//        NSKeyedArchiver.archiveRootObject(subjectData, toFile: filePath.path)
        do {
            let json = try JSONSerialization.data(withJSONObject: subjectData, options: [])
            FileManager.default.createFile(atPath: filePath.path, contents: json, attributes: nil)
            let success = FileManager.default.fileExists(atPath: (filePath.path))
            let content = try String(contentsOf: filePath)
            print("It was a success \(success) file: \(content)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func saveFaceVideo(trialPosition type: String) {
    }
    func saveBodyVideo() {
    }
    func saveE4() {
    }
    func saveBioECG() {
    }
    func saveBioGeneral() {
    }
}

