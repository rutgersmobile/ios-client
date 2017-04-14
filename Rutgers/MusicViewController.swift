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
    var channel : [NSObject : AnyObject]!
    let playImageName = "ic_play_arrow_white_48pt"
    let pauseImageName = "ic_pause_white_48pt"
    var sharingPopoverController : UIPopoverController? = nil
    var shareButton : UIBarButtonItem? = nil
    var streamUrl : String!
    var newTaskID = UIBackgroundTaskInvalid

    static var playHandle : AnyObject?
    static var pauseHandle : AnyObject?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var volumeContainerView: UIView!

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
        let storyboard = UIStoryboard(name: "MusicViewController", bundle: nil)
        let me = storyboard.instantiateInitialViewController() as! MusicViewController
        me.channel = channelConfiguration
        me.streamUrl = channelConfiguration["url"] as! String
        return me
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupPlayer() {
        MusicViewController.audioPlayer = AVPlayer(URL: NSURL(string: streamUrl)!)
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
            MusicViewController.playHandle = commandCenter.playCommand.addTargetWithHandler { event in
                self.recreateIfStopped()
                self.play()
                return .Success
            }
            commandCenter.pauseCommand.removeTarget(MusicViewController.pauseHandle)
            MusicViewController.pauseHandle = commandCenter.pauseCommand.addTargetWithHandler { event in
                self.pause()
                return .Success
            }
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

    func applicationWillEnterForeground() {
        recreateIfStopped()
        setupAudioSession()
        setPlayingState()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        newTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            UIApplication.sharedApplication().endBackgroundTask(self.newTaskID)
            self.newTaskID = UIBackgroundTaskInvalid
        }
        if (MusicViewController.audioPlayer == nil) {
            setupPlayer()
        } else {
            setPlayingState()
        }
        self.shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(actionButtonTapped))
        self.navigationItem.rightBarButtonItem = self.shareButton
        NSNotificationCenter
            .defaultCenter()
            .addObserver(
                self,
                selector: #selector(applicationWillEnterForeground),
                name: UIApplicationWillEnterForegroundNotification,
                object: nil
            )
    }

    override func viewWillAppear(animated: Bool) {
        setPlayingState()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        volumeContainerView.backgroundColor = UIColor.clearColor()
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
    
    func openWebView(url: NSURL) {
        if #available(iOS 8.0, *) {
            let vc = RUWKWebViewController(URL: url)
            vc.showPageTitles = false
            vc.hideWebViewBoundaries = true
            vc.showUrlWhileLoading = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = RUUIWebViewController(URL: url)
            vc.showPageTitles = false
            vc.hideWebViewBoundaries = true
            vc.showUrlWhileLoading = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func writeEmail(sender: UIButton) {
        if let url = NSURL(string: "mailto:wrnurutgersradio@gmail.com") {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    @IBAction func playRadio(sender: UIButton) {
        toggleRadio()
    }

    @IBAction func openTwitter(sender: UIButton) {
        if let url = NSURL(string: "https://twitter.com/WRNU") {
            openWebView(url)
        }
    }

    @IBAction func openInstagram(sender: UIButton) {
        if let url = NSURL(string: "https://www.instagram.com/_wrnu/") {
            openWebView(url)
        }
    }

    @IBAction func openFacebook(sender: UIButton) {
        if let url = NSURL(string: "https://www.facebook.com/CampusBeatRadio") {
            openWebView(url)
        }
    }

    @IBAction func openSoundcloud(sender: UIButton) {
        if let url = NSURL(string: "https://soundcloud.com/rutgers-wrnu") {
            openWebView(url)
        }
    }
}
