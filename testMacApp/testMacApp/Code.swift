//
//  Code.swift
//  testMacApp
//
//  Created by Пользователь on 17.12.2019.
//  Copyright © 2019 mintrocket. All rights reserved.
//

import Foundation


public struct TemplateParams {
    let templateProjectName = "XLProjectName"
    let templateBundleDomain = "XLOrganizationIdentifier"
    let templateAuthor = "XLAuthorName"
    let templateAuthorWebsite = "XLAuthorWebsite"
    let templateUserName = "XLUserName"
    let templateOrganizationName = "XLOrganizationName"

    var projectName = "MyProject"
    var bundleDomain = "com.mintrocket"
    var author = "Mintrocket"
    var authorWebsite = "https://mintrocket.com"
    var userName = "mintrocket"
    var organizationName = "Mintrocket"

    let fileManager = FileManager.default
}




public class Code {

    public var params = TemplateParams()

    let runScriptPathURL: NSURL?
    let currentScriptPathURL: NSURL?
    let iOSProjectTemplateForlderURL: NSURL?
    var newProjectFolderPath: String? = ""
    let ignoredFiles = [".DS_Store", "UserInterfaceState.xcuserstate"]

    init() {
        self.runScriptPathURL = NSURL(fileURLWithPath: self.params.fileManager.currentDirectoryPath, isDirectory: true)
        self.currentScriptPathURL = NSURL(fileURLWithPath: NSURL(fileURLWithPath: CommandLine.arguments[0], relativeTo: self.runScriptPathURL! as URL).deletingLastPathComponent!.path, isDirectory: true)
        self.iOSProjectTemplateForlderURL = NSURL(fileURLWithPath: "Project-iOS", relativeTo: currentScriptPathURL! as URL)
    }



    func printInfo<T>(message: T)  {
        print("\n-------------------Info:-------------------------")
        print("\(message)")
        print("--------------------------------------------------\n")
    }

    func printErrorAndExit<T>(message: T) {
        print("\n-------------------Error:-------------------------")
        print("\(message)")
        print("--------------------------------------------------\n")
        exit(1)
    }

    func checkThatProjectForlderCanBeCreated(projectURL: NSURL){
        var isDirectory: ObjCBool = true
        if self.params.fileManager.fileExists(atPath: projectURL.path!, isDirectory: &isDirectory){
            printErrorAndExit(message: "\(self.params.projectName) \(isDirectory.boolValue ? "folder already" : "file") exists in \(String(describing: runScriptPathURL?.path)) directory, please delete it and try again")
        }
    }

    func shell(args: String...) -> (output: String, exitCode: Int32) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.currentDirectoryPath = self.newProjectFolderPath!
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? ?? ""
        return (output, task.terminationStatus)
    }

    func prompt(message: String, defaultValue: String) -> String {
        print("\n> \(message) (or press Enter to use \(defaultValue))")
        let line = readLine()
        return line == nil || line == "" ? defaultValue : line!
    }

    func startGenerate() {

        print("\nLet's go over some question to create your base project code!")

        self.params.projectName = prompt(message: "Project name", defaultValue: self.params.projectName)
        print(self.params.projectName)

        // Check if folder already exists
        let newProjectFolderURL = NSURL(fileURLWithPath: self.params.projectName, relativeTo: self.runScriptPathURL! as URL)
        self.newProjectFolderPath = newProjectFolderURL.path!
        checkThatProjectForlderCanBeCreated(projectURL: newProjectFolderURL)

        self.params.bundleDomain = prompt(message: "Bundle domain", defaultValue: self.params.bundleDomain)
        self.params.author       = prompt(message: "Author", defaultValue: self.params.author)
        self.params.authorWebsite  = prompt(message: "Author Website", defaultValue: self.params.authorWebsite)
        self.params.userName     = prompt(message: "Github username", defaultValue: self.params.userName)
        self.params.organizationName = prompt(message: "Organization Name", defaultValue: self.params.organizationName)

        // Copy template folder to a new folder inside run script url called projectName
        do {
            try self.params.fileManager.copyItem(at: iOSProjectTemplateForlderURL! as URL, to: newProjectFolderURL as URL)
        } catch let error as NSError {
            printErrorAndExit(message: error.localizedDescription)
        }

        // rename files and update content
        let enumerator = self.params.fileManager.enumerator(at: newProjectFolderURL as URL, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: [], errorHandler: nil)!
        var directories = [NSURL]()
        print("\nCreating \(self.params.projectName) ...")
        while let fileURL = enumerator.nextObject() as? NSURL {
            guard !ignoredFiles.contains(fileURL.fileName) else { continue }
            if fileURL.isDirectory {
                directories.append(fileURL)
            }
            else {
                fileURL.updateContent(params: self.params)
                fileURL.renameIfNeeded(projectName: self.params.projectName)
            }
        }
        for fileURL in directories.reversed() {
            fileURL.renameIfNeeded(projectName: self.params.projectName)
        }
    }

    //print("git init\n")
    //print(shell(args: "git", "init").output)
    //print("git add .\n")
    //print(shell(args: "git", "add", ".").output)
    //print("git commit -m 'Initial commit'\n")
    //print(shell(args: "git", "commit", "-m", "'Initial commit'").output)
    //print("git remote add origin git@github.com:\(userName)/\(projectName).git\n")
    //print(shell(args: "git", "remote", "add", "origin", "git@github.com:\(userName)/\(projectName).git").output)
    //print("pod install --project-directory=\(projectName)\n")
    //print(shell(args: "pod", "install", "--project-directory=\(projectName)").output)
    //print("open \(projectName)/\(projectName).xcworkspace\n")
    //print(shell(args: "open", "\(projectName)/\(projectName).xcworkspace").output)

}

extension NSURL {
    var fileName: String {
        var fileName: AnyObject?
        try! self.getResourceValue(&fileName, forKey: URLResourceKey.nameKey)
        return fileName as! String
    }

    var isDirectory: Bool {
        var isDirectory: AnyObject?
        try! self.getResourceValue(&isDirectory, forKey: URLResourceKey.isDirectoryKey)
        return isDirectory as! Bool
    }

    func renameIfNeeded(projectName: String) {
        if let _ = fileName.range(of: "XLProjectName") {
            let renamedFileName = fileName.replacingOccurrences(of: "XLProjectName", with: projectName)
            try! FileManager.default.moveItem(at: self as URL, to: NSURL(fileURLWithPath: renamedFileName, relativeTo: deletingLastPathComponent) as URL)
        }
    }

    func updateContent(params: TemplateParams) {
        guard let path = path, let content = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
            print("ERROR READING: \(self)")
            return
        }
        var newContent = content.replacingOccurrences(of: params.templateProjectName, with: params.projectName)
        newContent = newContent.replacingOccurrences(of: params.templateBundleDomain, with: params.bundleDomain)
        newContent = newContent.replacingOccurrences(of: params.templateAuthor, with: params.author)
        newContent = newContent.replacingOccurrences(of: params.templateUserName, with: params.userName)
        newContent = newContent.replacingOccurrences(of: params.templateAuthorWebsite, with: params.authorWebsite)
        newContent = newContent.replacingOccurrences(of: params.templateOrganizationName, with: params.organizationName)
        try! newContent.write(to: self as URL, atomically: true, encoding: String.Encoding.utf8)
    }
}
