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

    let audioPlayer : AVPlayer?
    var playing = false
    let channel : [NSObject : AnyObject]
    let playImageName = "ic_play_arrow_white_48pt"
    let pauseImageName = "ic_pause_white_48pt"

    @IBOutlet weak var volumeContainerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var wrnuLogo: UIImageView!
    @IBOutlet weak var backgroundView: UIView!

    static func channelHandle() -> String!
    {
        return "Radio";
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
        return MusicViewController(channel: channelConfiguration)
    }

    init(channel: [NSObject : AnyObject]) {
        self.channel = channel
        self.audioPlayer = AVPlayer(URL: NSURL(string: channel["url"] as! String)!)
        super.init(nibName: .None, bundle: .None)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        backgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "wrnu_background")!)
        backgroundView.opaque = false
        backgroundView.layer.opaque = false
        NSNotificationCenter
            .defaultCenter()
            .addObserver(
                self,
                selector: #selector(setPlayingState),
                name: UIApplicationWillEnterForegroundNotification,
                object: nil
            )
    }

    override func viewWillAppear(animated: Bool) {
        setPlayingState()
    }

    func setPlayingState() {
        playing = audioPlayer?.rate != 0 && audioPlayer?.error == nil
        playButton?.setImage(UIImage(named: playing ? pauseImageName : playImageName), forState: .Normal)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        volumeContainerView.backgroundColor = UIColor.clearColor()
        let volumeView = MPVolumeView(frame: volumeContainerView.bounds)
        volumeContainerView.addSubview(volumeView)

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
            playButton.setImage(UIImage(named: pauseImageName), forState: .Normal)
            playing = true
        } else {
            audioPlayer?.pause()
            playButton.setImage(UIImage(named: playImageName), forState: .Normal)
            playing = false
        }
    }

    @IBAction func playRadio(sender: UIButton) {
        toggleRadio()
    }
}
