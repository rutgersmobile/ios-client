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

class MusicViewController: UIViewController , RUChannelProtocol, UIPopoverControllerDelegate
{

    static var audioPlayer : AVPlayer?
    var playing = false
    let channel : [NSObject : AnyObject]
    let playImageName = "ic_play_arrow_white_48pt"
    let pauseImageName = "ic_pause_white_48pt"
    var sharingPopoverController : UIPopoverController? = nil
    var shareButton : UIBarButtonItem? = nil
    let streamUrl : String
    var newTaskID = UIBackgroundTaskInvalid

    static var playHandle : AnyObject?
    static var pauseHandle : AnyObject?

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
        self.streamUrl = channel["url"] as! String
        super.init(nibName: .none, bundle: .none)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPlayer() {
        MusicViewController.audioPlayer = AVPlayer(URL: URL(string: streamUrl)!)
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle : "WRNU",
            MPMediaItemPropertyArtwork : MPMediaItemArtwork(image: UIImage(named: "radio_album")!)
        ]
    }

    func setupPlayerIfInvalid() {
        if (MusicViewController.audioPlayer == nil || MusicViewController.audioPlayer?.error != nil || newTaskID == UIBackgroundTaskInvalid) {
            setupPlayer()
        }
    }

    func recreateIfStopped() {
        if (MusicViewController.audioPlayer?.rate == 0) {
            MusicViewController.audioPlayer = nil
        }
        setupPlayerIfInvalid()
    }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        if #available(iOS 7.1, *) {
            let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
            commandCenter.playCommand.removeTarget(MusicViewController.playHandle)
            MusicViewController.playHandle = commandCenter.playCommand.addTargetWithHandler({ event in
                self.recreateIfStopped()
                self.play()
                return .Success
            })
            commandCenter.pauseCommand.removeTarget(MusicViewController.pauseHandle)
            MusicViewController.pauseHandle = commandCenter.pauseCommand.addTargetWithHandler({ event in
                self.pause()
                return .Success
            })
        }
    }

    func setPlayingState() {
        playing = MusicViewController.audioPlayer?.rate != 0 && MusicViewController.audioPlayer?.error == nil
        playButton?.setImage(UIImage(named: playing ? pauseImageName : playImageName), forState: .Normal)
    }

    func play() {
        setupPlayerIfInvalid()
        MusicViewController.audioPlayer?.play()
        self.playButton.setImage(UIImage(named: self.pauseImageName), forState: .Normal)
        self.playing = true
    }

    func pause() {
        setupPlayerIfInvalid()
        MusicViewController.audioPlayer?.pause()
        self.playButton.setImage(UIImage(named: self.playImageName), forState: .Normal)
        self.playing = false
    }

    func toggleRadio() {
        if (!playing) {
            play()
        } else {
            pause()
        }
    }
    
    func actionButtonTapped() {
        if let url = sharingURL() {
            let favoriteActivity = RUFavoriteActivity(title: "WRNU")
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [favoriteActivity])
            activityVC.excludedActivityTypes = [UIActivityType.print, UIActivityType.addToReadingList]
            if (UI_USER_INTERFACE_IDIOM() == .phone) {
                self.presentViewController(activityVC, animated: true, completion: nil)
                return
            }
            if let popover = self.sharingPopoverController {
                popover.dismiss(animated: false)
                self.sharingPopoverController = nil
            } else {
                self.sharingPopoverController = UIPopoverController(contentViewController: activityVC)
                self.sharingPopoverController?.delegate = self
                self.sharingPopoverController?.present(from: self.shareButton!, permittedArrowDirections: .any, animated: true)
            }
        }
    }

    func applicationWillEnterForeground() {
        recreateIfStopped()
        setupAudioSession()
        setPlayingState()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        newTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            UIApplication.sharedApplication().endBackgroundTask(self.newTaskID)
            self.newTaskID = UIBackgroundTaskInvalid
        })
        if (MusicViewController.audioPlayer == nil) {
            setupPlayer()
        } else {
            setPlayingState()
        }
        self.shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonTapped))
        self.navigationItem.rightBarButtonItem = self.shareButton
        backgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "wrnu_background")!)
        backgroundView.isOpaque = false
        backgroundView.layer.isOpaque = false
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(applicationWillEnterForeground),
                name: NSNotification.Name.UIApplicationWillEnterForeground,
                object: nil
            )
    }

    override func viewWillAppear(animated: Bool) {
        setPlayingState()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        volumeContainerView.backgroundColor = UIColor.clear
        let volumeView = MPVolumeView(frame: volumeContainerView.bounds)
        volumeContainerView.addSubview(volumeView)

        setupAudioSession()
    }

    func actionButtonTapped() {
        if let url = sharingURL() {
            let favoriteActivity = RUFavoriteActivity(title: "WRNU")
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [favoriteActivity])
            activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAddToReadingList]
            if (UI_USER_INTERFACE_IDIOM() == .Phone) {
                self.presentViewController(activityVC, animated: true, completion: nil)
                return
            }
            if let popover = self.sharingPopoverController {
                popover.dismissPopoverAnimated(false)
                self.sharingPopoverController = nil
            } else {
                self.sharingPopoverController = UIPopoverController(contentViewController: activityVC)
                self.sharingPopoverController?.delegate = self
                self.sharingPopoverController?.presentPopoverFromBarButtonItem(self.shareButton!, permittedArrowDirections: .Any, animated: true)
            }
        }
    }

    func sharingURL() -> NSURL? {
        return DynamicTableViewController.buildDynamicSharingURL(self.navigationController!, channel: self.channel)
    }

    @IBAction func playRadio(sender: UIButton) {
        toggleRadio()
    }
}
