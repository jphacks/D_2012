//
//  ViewController.swift
//  statusbar
//
//  Created by 武久宗平 on 2020/10/31.
//

import Cocoa
import AppKit
class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url: URL = URL(string: "https://broadcaster-test-5cxvgnwmhq-uc.a.run.app/v1")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            // コンソールに出力
            print("data: \(String(describing: data))")
            print("response: \(String(describing: response))")
            print("error: \(String(describing: error))")
        })
        task.resume()                // Do any additional setup after loading the view.
    }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var timer: Timer?
    var count: Int = 0
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
// Create the SwiftUI view that provides the window contents.
        //viewDidLoad()
        print("fd")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.onTimer(_:)), userInfo: nil, repeats: true)
        
    }
    @objc func onTimer(_ timer: Timer) {
        
        if (count == 0) {
            
        if let button = statusItem.button {
            let size = NSMakeSize(22, 22)
            let image = NSImage(named:NSImage.Name("ps1"))
            image?.size = size
            button.image = image
            count = 1}
        } else if (count == 1){
        
        if let button = statusItem.button {
        let size = NSMakeSize(22, 22)
        let image = NSImage(named:NSImage.Name("ps2"))
        image?.size = size
        //button.image = NSImage(named:NSImage.Name("ps1"))
        button.image = image
        count = 0
    }
    }
        print("onTimer")}
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    }
    
    
    
    //override var representedObject: Any? {
     //   didSet {
        // Update the view, if already loaded.
       // }
    //}
    




