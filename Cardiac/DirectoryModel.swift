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
    
    // Actions for connectivityManager delegates to listen for
    let START_EXP = "startExperiment"
    let START_VID = "startVideo"
    let STOP_VID = "stopVideo"
    let SUBMIT_VID = "submitVideo"
    let SUBMIT_RND = "submitRound"
    let RESET_RND = "resetRound"
    
    // For Connectivity manager
    let SERVICE_TYPE = "cardiac"
    
    static let sharedInstance = DirectoryModel()
    
    let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var rootDirectoryURL: URL
    var subjectDirectoryURL: URL?
    
    var phoneMode: String?
    var subjectData = [String: Any]()
    var trialList = [[String: Any]]()
    
    var trialStartTime: Double?
    var trialEndTime: Double?
    
    var videoFilePath: URL?
    var E4FilePath: URL?
    var BHInfo: [String: Any]?
    
    var subDirNum: Int = 0
    
    init() {
        self.rootDirectoryURL = URL.init(fileURLWithPath: "cardiacData", relativeTo: documentsURL)
        print(rootDirectoryURL.path)
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            if directoryContents.count == 0 {
                try FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }
//            else {
//                try FileManager.default.removeItem(at: rootDirectoryURL)
//                self.rootDirectoryURL.appendPathExtension("+")
//                print(rootDirectoryURL.absoluteString)
//                try FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: true, attributes: nil)
//            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // starts when demographic data is submitted
    func startBodySession(demographicData: [String:Any], overwriteExistingSession overwrite: Bool = false) -> (success: Bool, error: String)? {
        self.phoneMode = BODY
        self.subjectData["phoneMode"] = BODY
        self.subjectData["subjectID"] = demographicData["subjectID"] as! String
        self.subjectData["demographicData"] = demographicData
        return createSubjectDirectory(directoryName: String(describing: subjectData["subjectID"]!) + String(describing:subjectData["phoneMode"]!), overwriteExistingSession: overwrite)
    }
    
    //Starts when subjectID is submitted
    func startFaceSession(subjectID: String, overwriteExistingSession overwrite: Bool = false) ->
        (success: Bool, error: String)? {
        self.phoneMode = FACE
        self.subjectData["phoneMode"] = FACE
        self.subjectData["subjectID"] = subjectID
        return createSubjectDirectory(directoryName: String(describing: subjectData["subjectID"]!) + String(describing: subjectData["phoneMode"]!), overwriteExistingSession: overwrite)
    }
    
    //Creates subject's root directory (can overwrite previously created directories)
    func createSubjectDirectory(directoryName: String, overwriteExistingSession overwrite: Bool = false)
        -> (success: Bool, error: String)? {
            print("rootDirectoryURL" + rootDirectoryURL.path)
//            let newURL = URL.init(fileURLWithPath: directoryName, relativeTo: rootDirectoryURL)
            let newURL = URL.init(fileURLWithPath: "cardiacData/" + directoryName, relativeTo: documentsURL)
//            print("newURL" + newURL.path)
            let subjectAlreadyExists = FileManager.default.fileExists(atPath: newURL.path)
            createDirectory: do {
                if subjectAlreadyExists {
                    if overwrite {
                        try FileManager.default.removeItem(at: newURL)
                    } else {
                        print("SubjectID has already been used. Using existing directory")
                        break createDirectory
                    }
                }
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false, attributes: nil)
                self.subDirNum += 1
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
            "startTime": trialStartTime!,
            "endTime": trialEndTime!,
            "positionType": POSITIONS[trialList.count],
            "faceCamFilePath": videoFilePath!.absoluteString,
            "BHInfo": BHInfo!
        ] as [String : Any]
        self.trialList.append(tempDictionary)
    }
    
    func saveBodyTrialRound(manualEntryData manualData: [String:Any]) {
        let tempDictionary = [
            "startTime": trialStartTime!,
            "endTime": trialEndTime!,
            "positionType": POSITIONS[trialList.count],
            "bodyCamFilePath": videoFilePath!.absoluteString,
//            "E4FilePath": E4FilePath!.absoluteString,
            "E4FilePath": "E3filepath",
            "manualEntry": manualData
        ] as [String : Any]
        self.trialList.append(tempDictionary)
    }
    
    
    //Saving Subject's MetadataFile
    func finishSubjectSession() {
        subjectData["trailList"] = trialList
        let filePath = URL.init(fileURLWithPath: "metaData.json", relativeTo: subjectDirectoryURL)
        do {
            let json = try JSONSerialization.data(withJSONObject: subjectData, options: [JSONSerialization.WritingOptions.prettyPrinted])
            FileManager.default.createFile(atPath: filePath.path, contents: json, attributes: nil)
            
            resetModel()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func generateVideoFileURL() -> (URL){
        let filePath = String(describing: subjectData["subjectID"]!) + POSITIONS[trialList.count] + String(describing: subjectData["phoneMode"]!)
        var version = 0
        repeat {
            version += 1
            self.videoFilePath = URL.init(fileURLWithPath: filePath + String(version) + ".mov", relativeTo: subjectDirectoryURL)
        } while FileManager.default.fileExists(atPath: self.videoFilePath!.path)
        return videoFilePath!
    }
    
    func resetModel() {
        self.BHInfo = nil
        self.videoFilePath = nil
        self.E4FilePath = nil
        self.subjectDirectoryURL = nil
        self.subjectData = [String: Any]()
        self.trialList = [[String: Any]]()
    }
}

