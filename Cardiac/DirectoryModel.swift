//
//  DirectoryModel.swift
//  Cardiac
//
//  Created by Eileen Guo on 3/29/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import UIKit

class DirectoryModel {
    let FACE: String = "faceCam"
    let BODY: String = "bodyCam"
    let POSITIONS: [String] = ["supine", "sitting", "sevens", "standing"]
    
    static let sharedInstance = DirectoryModel()
    let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let rootDirectoryURL: URL
    var subjectDirectoryURL: URL?
    
    var subjectData = [String: Any]()
    var trialList = [[String: Any]]()
    
    var trialStartTime: Date = Date() //TEMP What do we want these to be exactly?
    var trialEndTime: Date = Date() //TEMP
    
    var videoFilePath: URL?
    var E4FilePath: URL?
    var bioECGFilePath: URL?
    var bioGeneralFilePath: URL?
    
    init() {
        self.rootDirectoryURL = URL.init(fileURLWithPath: "cardiacData", relativeTo: documentsURL)
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            if directoryContents.count == 0 {
                try FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: false, attributes: nil)
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
        self.subjectData["subjectID"] = Int(demographicData["subjectID"] as! String)
        self.subjectData["demographicData"] = demographicData
        return createSubjectDirectory(directoryName: String(describing: subjectData["subjectID"]!) + String(describing:subjectData["phoneMode"]!), overwriteExistingSession: overwrite)
    }
    
    //Starts when subjectID is submitted
    func startFaceSession(subjectID: String, overwriteExistingSession overwrite: Bool = false) ->
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
            return nil
    }
    
    // Saving data from each round (sevens, sitting, standing, etc.) to the trial list
    func saveFaceTrailRound() {
        let tempDictionary = [
            "startTime": trialStartTime.description,
            "endTime": trialEndTime.description,
            "positionType": POSITIONS[trialList.count],
            "faceCamFilePath": videoFilePath!,
            "bioECGFilePath": bioECGFilePath ?? "",
            "bioGeneralFilePath": bioGeneralFilePath ?? ""
        ] as [String : Any]
        self.trialList.append(tempDictionary)
    }
    func saveBodyTrialRound(manualEntryData manualData: [String:Any]) {
        let tempDictionary = [
            "startTime": trialStartTime.description,
            "endTime": trialEndTime.description,
            "positionType": POSITIONS[trialList.count],
            "bodyCamFilePath": videoFilePath!,
            "E4FilePath": E4FilePath ?? "",
            "manualEntry": manualData
        ] as [String : Any]
        self.trialList.append(tempDictionary)
    }
    
    //Saving Subject's MetadataFile
    func finishSubjectSession() {
        subjectData["trailList"] = trialList
        let filePath = URL.init(fileURLWithPath: "metaData.json", relativeTo: subjectDirectoryURL)
        do {
            print(subjectData)
            let json = try JSONSerialization.data(withJSONObject: subjectData, options: [JSONSerialization.WritingOptions.prettyPrinted])
            FileManager.default.createFile(atPath: filePath.path, contents: json, attributes: nil)
            
            self.bioECGFilePath = nil
            self.bioGeneralFilePath = nil
            self.videoFilePath = nil
            self.E4FilePath = nil
            self.subjectDirectoryURL = nil
            self.subjectData = [String: Any]()
            self.trialList = [[String: Any]]()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func generateVideoFileURL() -> (URL){
        let filePath = String(describing: subjectData["subjectID"]!) + POSITIONS[trialList.count] + String(describing: subjectData["phoneMode"]!) + ".mov"
        self.videoFilePath = URL.init(fileURLWithPath: filePath, relativeTo: subjectDirectoryURL)
        return videoFilePath!
    }

}

