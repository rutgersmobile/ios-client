//
//  MusicViewController.swift
//  Rutgers
//
//  Created by scm on 12/16/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicViewController: UIViewController , RUChannelProtocol
{

    var audioPlayer : AVPlayer?
    var playing = false

    @IBOutlet weak var playButton: UIButton!

    static func channelHandle() -> String!
    {
        return "music";
    }
    /*
     Every class is register with the RUChannelManager by calling a register class static method in the load function of each class.
     The load is called in objc on every class by the run time library...
     The load handles the registration process .
     */
    static func registerClass()
    {
        RUChannelManager.sharedInstance().registerClass(MusicViewController.self)
    }
    
    static func channelWithConfiguration(channelConfiguration: [NSObject : AnyObject]!) -> AnyObject!
    {
        return MusicViewController();
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        audioPlayer = AVPlayer(URL: NSURL(string: "http://crystalout.surfernetwork.com:8001/WRNU-FM_MP3")!)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setPlayingState), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        setPlayingState()
        print("dank")
    }

    func setPlayingState() {
        playing = audioPlayer?.rate != 0 && audioPlayer?.error == nil
        playButton?.setTitle(playing ? "Pause" : "Play", forState: .Normal)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("memes")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        if #available(iOS 7.1, *) {
            let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
            commandCenter.playCommand.addTargetWithHandler({ event in
                self.toggleRadio()
                return .Success
            })
            commandCenter.pauseCommand.addTargetWithHandler({ event in
                self.toggleRadio()
                return .Success
            })
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func toggleRadio() {
        if (!playing) {
            audioPlayer?.play()
            playButton.setTitle("Pause", forState: .Normal)
            playing = true
        } else {
            audioPlayer?.pause()
            playButton.setTitle("Play", forState: .Normal)
            playing = false
        }
    }


    @IBAction func playRadio(sender: AnyObject) {
        toggleRadio()
    }
  
}
