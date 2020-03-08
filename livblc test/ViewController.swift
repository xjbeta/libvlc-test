//
//  ViewController.swift
//  livblc test
//
//  Created by xjbeta on 2020/2/14.
//  Copyright © 2020 xjbeta. All rights reserved.
//

import Cocoa
import VLCKit

class ViewController: NSViewController {

    @IBAction func b(_ sender: Any) {
        p.play()
        
    }
    
    @IBAction func p(_ sender: Any) {
        
    }
    
    @IBOutlet weak var vView: VLCVideoView!
    let p = VLCMediaPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        p.setVideoView(vView)
        p.media = .init(path: "/Users/xjbeta/Movies/Shelter.mkv")
        

    }

    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
