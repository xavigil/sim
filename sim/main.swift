//
//  main.swift
//  sim
//
//  Created by Xavi Gil on 12/05/16.
//  Copyright © 2016 Xavi Gil. All rights reserved.
//

import Foundation

import Foundation

let doc : String = "iOS simulator helper.\n" +
    "\n" +
    "Usage:\n" +
    "  sim path [-o]\n" +
    "\n" +
    "Examples:\n" +
    "  sim path\n" +
    "\n" +
    "Options:\n" +
"  -h, --help\n"

var args = Process.arguments
args.removeAtIndex(0) // arguments[0] is always the program_name
let result = Docopt.parse(doc, argv: args, help: true, version: "1.0")

let homePath = NSHomeDirectory()
let simFolder = "\(homePath)/Library/Developer/CoreSimulator/Devices/"
let simFolderUrl = NSURL(fileURLWithPath: simFolder)

let fileManager = NSFileManager.defaultManager()

guard fileManager.fileExistsAtPath(simFolder) else {
    print("error path not found \(simFolder)")
    exit(1)
}

let enumerator = fileManager.enumeratorAtURL(
    simFolderUrl,
    includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey, NSURLAttributeModificationDateKey],
    options: [.SkipsHiddenFiles, .SkipsSubdirectoryDescendants ],
    errorHandler: nil)!

var lastModifiedFolder = (name: "", date: NSDate(timeIntervalSince1970: 0))
while let folder = enumerator.nextObject() as? NSURL{
    var filenameValue: AnyObject?
    var modifiedDateValue: AnyObject?
    var isDirectoryValue: AnyObject?
    try folder.getResourceValue(&isDirectoryValue, forKey: NSURLIsDirectoryKey)
    guard let isDirectory = isDirectoryValue as? Bool else {
        break
    }
    if isDirectory {
        try folder.getResourceValue(&filenameValue, forKey: NSURLNameKey)
        try folder.getResourceValue(&modifiedDateValue, forKey: NSURLAttributeModificationDateKey)
        let folderInfo = (name: filenameValue as! String, date: modifiedDateValue as! NSDate)
        if folderInfo.date.compare(lastModifiedFolder.date) == .OrderedDescending {
            lastModifiedFolder = folderInfo
        }
    }
}
//print(lastModifiedFolder)

let lastSimFolder = "\(simFolder)\(lastModifiedFolder.name)/data/Containers/Data/Application"
print(lastSimFolder)

func shell(args: String...) -> Int32 {
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

guard let open = result["-o"] as? Bool else {
    exit(0)
}
if open {
    shell("open", lastSimFolder)
}
exit(0)
