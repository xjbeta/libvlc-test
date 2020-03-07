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
        printInfo()
    }
    
    @IBOutlet weak var vView: NSView!
    
    var instance: OpaquePointer?
    var mediaPlayer: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let pluginPath = "/Applications/livblc test.app/Contents/Frameworks/plugins"
        let pluginPath = "/Applications/VLC.app/Contents/Frameworks/plugins"
//        let pluginPath = "/Applications/VLC.app/Contents/MacOS/plugins"
        
        
        //        let pluginPath = Bundle.main.privateFrameworksPath!
        
        if setenv("VLC_PLUGIN_PATH", pluginPath, 1) != 0 {
            print("Set plugins path error \(errno)")
        }
        
        //      let luaPath = "/Applications/VLC.app/Contents/Frameworks/lua"
        //        if setenv("VLC_PLUGIN_PATH", pluginPath, 1) != 0 {
        //            print("Set plugins path error \(errno)")
        //        }
        
        
        let args = [String]()
        
        //        --codec
//        let args = [
//            "--no-color",
//            "--no-video-title-show",
//            "--verbose=4",
//            "--no-sout-keep",
//            "--vout=macosx",
//            "--text-renderer=freetype",
//            "--extraintf=macosx_dialog_provider",
//            "--audio-resampler=soxr"]
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
        
        
//        libvlc_media_player_set_nsobject(mediaPlayer, vv)
        
        let s = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        var reportOpaqueCB: ((UnsafeMutableRawPointer?, UInt32, UInt32) -> Void)? = { _, _, _ in
            print("output_callbacks", "reportOpaqueCB")
            
            
        }
        
        let setup: libvlc_video_output_setup_cb = { (opaque, cfg, info) -> Bool in
            print("output_callbacks", "setup")
            return true
        }
        
        let cleanup: libvlc_video_output_cleanup_cb = { opaque in
            print("output_callbacks", "cleanup")
            

        }
        
        let resize: libvlc_video_output_set_resize_cb = { (opaque, reportOpaqueCB, reportOpaque) in
            print("output_callbacks", "resize")
            
            
        }
        
        let updateOutput: libvlc_video_update_output_cb = { (opaque, cfg, output) -> Bool in
            print("output_callbacks", "updateOutput")
            
            
            return true
        }
        
        let swap: libvlc_video_swap_cb = { (opaque) in
            print("output_callbacks", "swap")
            
        }
        
        let makeCurrent: libvlc_video_makeCurrent_cb = { (opaque, enter) -> Bool in
            print("output_callbacks", "makeCurrent")
            
            
            return true
        }
        
        let getProcAddress: libvlc_video_getProcAddress_cb = { (opaque, fctName) -> UnsafeMutableRawPointer? in
            print("output_callbacks", "getProcAddress")
            
            
            return nil
        }
        
        let metadata: libvlc_video_frameMetadata_cb = { (opaque, type, metadata) in
            print("output_callbacks", "metadata")
            
            
        }
        
        let selectPlane: libvlc_video_output_select_plane_cb = { (opaque, plane) -> Bool in
            
            print("output_callbacks", "selectPlane")
            
            return true
        }
        
        
        
        libvlc_video_set_output_callbacks(
            mediaPlayer,
            libvlc_video_engine_opengl,
            setup,
            cleanup,
            resize,
            updateOutput,
            swap,
            makeCurrent,
            getProcAddress,
            metadata,
            selectPlane,
            s)
    }

    func printInfo() {
        let hasVout = libvlc_media_player_has_vout(mediaPlayer)

        print(hasVout)
        
        
        guard let o = libvlc_media_player_get_nsobject(mediaPlayer) else { return }
        
        let v = Unmanaged<NSView>.fromOpaque(o).takeUnretainedValue()
        
        print(v)
        

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
            guard let s = str?.toString(), s != "waiting decoder fifos to empty" else { return }
            
            print("VLC LOG: \(s)")
            
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
