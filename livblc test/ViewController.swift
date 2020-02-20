//
//  ViewController.swift
//  livblc test
//
//  Created by xjbeta on 2020/2/14.
//  Copyright © 2020 xjbeta. All rights reserved.
//

import Cocoa
import Darwin

class ViewController: NSViewController {

    @IBAction func b(_ sender: Any) {
//        let libvlcInstance = instance?.pointee
//
//        let libvlcInt = libvlcInstance?.p_libvlc_int.pointee
//        let obj = libvlcInt?.obj
        
//        let intfThread = obj as! intf_thread_t
        
        
        libvlc_media_player_play(mediaPlayer)
        
    }
    
    @IBAction func p(_ sender: Any) {
        guard let o = libvlc_media_player_get_nsobject(mediaPlayer) else { return }
        
        let v = Unmanaged<NSView>.fromOpaque(o).takeUnretainedValue()
        
        print(v)
        
        let hasVout = libvlc_media_player_has_vout(mediaPlayer)
        
        print(hasVout)
    }
    
    @IBOutlet weak var vView: NSView!
    
    var instance: OpaquePointer?
    var mediaPlayer: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let pluginPath = "/Applications/livblc test.app/Contents/Frameworks/plugins"
//        let pluginPath = "/Applications/VLC.app/Contents/Frameworks/plugins"
        let pluginPath = "/Applications/VLC.app/Contents/MacOS/plugins"
        
        
        //        let pluginPath = Bundle.main.privateFrameworksPath!
        
        if setenv("VLC_PLUGIN_PATH", pluginPath, 1) != 0 {
            print("Set plugins path error \(errno)")
        }
        
        //      let luaPath = "/Applications/VLC.app/Contents/Frameworks/lua"
        //        if setenv("VLC_PLUGIN_PATH", pluginPath, 1) != 0 {
        //            print("Set plugins path error \(errno)")
        //        }
        
        
        //        let args = [String]()
        
        //        --codec
        let args = [
            "--no-color",
            "--no-video-title-show",
            "--verbose=4",
            "--no-sout-keep",
            "--vout=macosx",
            "--text-renderer=freetype",
//            "--extraintf=macosx_dialog_provider",
            "--audio-resampler=soxr"]
        let argv: [UnsafePointer<Int8>?] = args.map({ $0.withCString({ $0 }) })
        
                let mrl = "file:///Users/xjbeta/Movies/Shelter.mkv"
//        let mrl = "file:///Users/xjbeta/Movies/t1.mp4"
        
        //VLCVideoOutputProvider
        //        mediaplayerfa
        
        
        instance = libvlc_new(Int32(args.count), argv)
        
        libvlc_set_app_id(instance, "com.xjbeta.livblc-test", "1.0", "foobar")
        
        enableLogging(.error)
        
        let v = vView!
        let vv = UnsafeMutableRawPointer(Unmanaged.passUnretained(v).toOpaque())
        
        
        let mediaI = libvlc_media_new_location(instance, mrl)
        
        mediaPlayer = libvlc_media_player_new_from_media(mediaI)
        
        
        libvlc_media_player_set_nsobject(mediaPlayer, vv)
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    enum LogLevel: Int32 {
        case info = 0
        case error = 1
        case warning = 2
        case debug = 4
    }
    
    
    func enableLogging(_ level: LogLevel = .debug) {
        guard let i = instance else { return }

        libvlc_log_set(i, { data, level, ctx, fmt, args in
            var str: UnsafeMutablePointer<Int8>?
            if vasprintf(&str, fmt, args) == -1 {
                if str != nil {
                    free(str)
                }
            }
            guard let s = str else { return }
            
            print("VLC LOG: \(s.toString())")
            
        }, Unmanaged.passUnretained(self).toOpaque())
    }
}


extension UnsafePointer where Pointee == Int8 {
    func toString() -> String {
        return String(cString: self)
    }
}

extension UnsafeMutablePointer where Pointee == Int8 {
    func toString() -> String {
        return String(cString: self)
    }
}

extension String {
    func cString() -> UnsafePointer<Int8>? {
        return NSString(string: self).utf8String
    }
}
