//import Foundation
//
//extension NSURL {
//    var fileName: String {
//        var fileName: AnyObject?
//        try! getResourceValue(&fileName, forKey: URLResourceKey.nameKey)
//        return fileName as! String
//    }
//
//    var isDirectory: Bool {
//        var isDirectory: AnyObject?
//        try! getResourceValue(&isDirectory, forKey: URLResourceKey.isDirectoryKey)
//        return isDirectory as! Bool
//    }
//
//    func renameIfNeeded() {
//        if let _ = fileName.range(of: "XLProjectName") {
//            let renamedFileName = fileName.replacingOccurrences(of: "XLProjectName", with: projectName)
//            try! FileManager.default.moveItem(at: self as URL, to: NSURL(fileURLWithPath: renamedFileName, relativeTo: deletingLastPathComponent) as URL)
//        }
//    }
//
//    func updateContent(templateProjectName: String, projectName: String) {
//        guard let path = path, let content = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
//            print("ERROR READING: \(self)")
//            return
//        }
//        var newContent = content.replacingOccurrences(of: templateProjectName, with: projectName)
//        newContent = newContent.replacingOccurrences(of: templateBundleDomain, with: bundleDomain)
//        newContent = newContent.replacingOccurrences(of: templateAuthor, with: author)
//        newContent = newContent.replacingOccurrences(of: templateUserName, with: userName)
//        newContent = newContent.replacingOccurrences(of: templateAuthorWebsite, with: authorWebsite)
//        newContent = newContent.replacingOccurrences(of: templateOrganizationName, with: organizationName)
//        try! newContent.write(to: self as URL, atomically: true, encoding: String.Encoding.utf8)
//    }
//}
