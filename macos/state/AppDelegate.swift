//
//  AppDelegate.swift
//  state
//
//  Created by 武久宗平 on 2020/10/31.
//

import Cocoa
import SwiftUI
import AppKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menubar: NSMenu!
    
    override init(){
        self.ratioData = [String: Any]()
        self.count = -1
    }
    private var ratioData: [String: Any]
    private var count: Double
    private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    private var timer: Timer?
    private var frames1 = [[NSImage]]()
    private var frames2 = [[NSImage]]()
    private var frames3 = [[NSImage]]()
    private var cnt: Int = 0
    private var size = NSMakeSize(22, 22)
    private var isApple: Bool = true
    private var isCovid19: Bool = false
    private var isEnergy: Bool = false
    private var isStar: Bool = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        
        setImage()
        start()
        
    }
    func setImage(){//状態１ー３の画像をframesにセット
        for _ in (0 ..< 4){
            frames1.append([NSImage]())
            frames2.append([NSImage]())
            frames3.append([NSImage]())
        }
        
        
        for i in (1 ..< 6) {
            var image = (NSImage(imageLiteralResourceName: "covid19-\(i)"))
            image.size = size
            frames1[0].append(image)
            image = (NSImage(imageLiteralResourceName: "covid19-2-\(i)"))
            image.size = size
            frames2[0].append(image)
            image = (NSImage(imageLiteralResourceName: "covid19-3-\(i)"))
            image.size = size
            frames3[0].append(image)
        }
        statusItem.button?.image = frames1[0][cnt]
        statusItem.button?.image = frames2[0][cnt]
        statusItem.button?.image = frames3[0][cnt]
        
        for i in (1 ..< 6) {
            var image = (NSImage(imageLiteralResourceName: "energy-1-\(i)"))
            image.size = size
            frames1[1].append(image)
            image = (NSImage(imageLiteralResourceName: "energy-2-\(i)"))
            image.size = size
            frames2[1].append(image)
            image = (NSImage(imageLiteralResourceName: "energy-3-\(i)"))
            image.size = size
            frames3[1].append(image)
        }
        statusItem.button?.image = frames1[1][cnt]
        statusItem.button?.image = frames2[1][cnt]
        statusItem.button?.image = frames3[1][cnt]
        
        for i in (1 ..< 6) {
            var image = (NSImage(imageLiteralResourceName: "star-1-\(i)"))
            image.size = size
            frames1[2].append(image)
            image = (NSImage(imageLiteralResourceName: "star-2-\(i)"))
            image.size = size
            frames2[2].append(image)
            image = (NSImage(imageLiteralResourceName: "star-3-\(i)"))
            image.size = size
            frames3[2].append(image)
        }
        statusItem.button?.image = frames1[2][cnt]
        statusItem.button?.image = frames2[2][cnt]
        statusItem.button?.image = frames3[2][cnt]
        
        for i in (1 ..< 6) {
            var image = (NSImage(imageLiteralResourceName: "apple-1-\(i)"))
            image.size = size
            frames1[3].append(image)
            image = (NSImage(imageLiteralResourceName: "apple-2-\(i)"))
            image.size = size
            frames2[3].append(image)
            image = (NSImage(imageLiteralResourceName: "apple-3-\(i)"))
            image.size = size
            frames3[3].append(image)
        }
        statusItem.button?.image = frames1[3][cnt]
        statusItem.button?.image = frames2[3][cnt]
        statusItem.button?.image = frames3[3][cnt]
        
        
        
        
        statusItem.menu = menubar
        statusItem.button?.imagePosition = .imageRight
        
        
        cnt = (cnt + 1) % frames1[0].count
    }
    
    func start(){
        //最初にURLから混雑具合ratioを取得
        self.viewDidLoad()
        //一定時間毎にURLから混雑具合ratioを取得して値を更新
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (t) in
            self.viewDidLoad()
        })
        //再帰構造で無限ループさせてアニメーションをさせる
        animate()
    }
    
    func viewDidLoad() {
        
        let url: URL = URL(string: "https://broadcaster-test-5cxvgnwmhq-uc.a.run.app/v1/fake")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
        // コンソールに出力
        
        do{
            self.ratioData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            print(self.ratioData) // Jsonの中身を表示]
            let foo: Double? = self.ratioData["ratio"] as? Double
            self.count = foo!
                
            }
            catch {
            print(error)
                 }
        })
        task.resume()
    }
    func animate() {
        switch self.count{
        case 0.0...0.33:
            print("0-0.3")
            if isCovid19 {
                statusItem.button?.image = frames1[0][cnt]
            }
            if isEnergy {
                statusItem.button?.image = frames1[1][cnt]
            }
            if isStar {
                statusItem.button?.image = frames1[2][cnt]
            }
            if isApple {
                statusItem.button?.image = frames1[3][cnt]
            }
            
        case 0.33...0.66:
            print("0.3-0.6")
            if isCovid19 {
                statusItem.button?.image = frames2[0][cnt]
            }
            if isEnergy {
                statusItem.button?.image = frames2[1][cnt]
            }
            if isStar {
                statusItem.button?.image = frames2[2][cnt]
            }
            if isApple {
                statusItem.button?.image = frames2[3][cnt]
            }
        case 0.66...1:
            print("0.66-1の値")
            if isCovid19 {
                statusItem.button?.image = frames3[0][cnt]
            }
            if isEnergy {
                statusItem.button?.image = frames3[1][cnt]
            }
            if isStar {
                statusItem.button?.image = frames3[2][cnt]
            }
            if isApple {
                statusItem.button?.image = frames3[3][cnt]
            }
            
        default:
            print("範囲外の値")
        }
        cnt = (cnt + 1) % frames1[0].count
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.animate()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
   
    @IBAction func push_covid19(_ sender: Any) {
        isCovid19 = true
        isStar = false
        isEnergy = false
        isApple = false
        
    }
    @IBAction func push_energy(_ sender: Any) {
        isCovid19 = false
        isStar = false
        isEnergy = true
        isApple = false
    }
    @IBAction func push_star(_ sender: Any) {
        isCovid19 = false
        isStar = true
        isEnergy = false
        isApple = false
    }
    @IBAction func push_apple(_ sender: Any) {
        isCovid19 = false
        isStar = false
        isEnergy = false
        isApple = true
    }
    @IBAction func push_quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}


    

struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
