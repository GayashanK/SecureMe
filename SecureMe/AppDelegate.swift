//
//  AppDelegate.swift
//  SecureMe
//
//  Created by Kasun Gayashan on 28/05/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let vc =   CameraViewController()
        self.window.contentViewController = vc
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func openFolder(_ sender: Any) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        self.showInFinder(url: path)
    }
    
    private func showInFinder(url: URL?) {
        guard let url = url else { return }
        
        if url.isFileURL {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        }
    }
    
}
