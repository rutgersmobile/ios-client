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

@objcMembers
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
        RUChannelManager.sharedInstance().register(MusicViewController.self)
    }

    static func channel(withConfiguration channelConfiguration: [AnyHashable : Any]!) -> Any!
    {
        let storyboard = UIStoryboard(name: "MusicViewController", bundle: nil)
        let me = storyboard.instantiateInitialViewController() as! MusicViewController
        me.channel = channelConfiguration as [NSObject : AnyObject]
        me.streamUrl = channelConfiguration["url"] as! String
        return me
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupPlayer() {
        MusicViewController.audioPlayer = AVPlayer(url: URL(string: streamUrl)!)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
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
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.playCommand.removeTarget(MusicViewController.playHandle)
            MusicViewController.playHandle = commandCenter.playCommand.addTarget { event in
                self.recreateIfStopped()
                self.play()
                return .success
            } as AnyObject
            commandCenter.pauseCommand.removeTarget(MusicViewController.pauseHandle)
            MusicViewController.pauseHandle = commandCenter.pauseCommand.addTarget { event in
                self.pause()
                return .success
            } as AnyObject
        }
    }

    func setPlayingState() {
        playing = MusicViewController.audioPlayer?.rate != 0 && MusicViewController.audioPlayer?.error == nil
        playButton?.setImage(UIImage(named: playing ? pauseImageName : playImageName), for: [])
    }

    func play() {
        setupPlayerIfInvalid()
        MusicViewController.audioPlayer?.play()
        self.playButton.setImage(UIImage(named: self.pauseImageName), for: [])
        self.playing = true
    }

    func pause() {
        setupPlayerIfInvalid()
        MusicViewController.audioPlayer?.pause()
        self.playButton.setImage(UIImage(named: self.playImageName), for: [])
        self.playing = false
    }

    func toggleRadio() {
        if (!playing) {
            play()
        } else {
            pause()
        }
    }

    @objc func applicationWillEnterForeground() {
        recreateIfStopped()
        setupAudioSession()
        setPlayingState()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        newTaskID = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.newTaskID)
            self.newTaskID = UIBackgroundTaskInvalid
        }
        if (MusicViewController.audioPlayer == nil) {
            setupPlayer()
        } else {
            setPlayingState()
        }
        self.shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonTapped))
        self.navigationItem.rightBarButtonItem = self.shareButton
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(applicationWillEnterForeground),
                name: .UIApplicationWillEnterForeground,
                object: nil
            )
    }

    override func viewWillAppear(_ animated: Bool) {
        setPlayingState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        volumeContainerView.backgroundColor = UIColor.clear
        let volumeView = MPVolumeView(frame: volumeContainerView.bounds)
        volumeContainerView.addSubview(volumeView)

        setupAudioSession()
    }

    override func actionButtonTapped() {
        if let url = sharingURL() {
            let favoriteActivity = RUFavoriteActivity(title: "WRNU")
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [favoriteActivity!])
            activityVC.excludedActivityTypes = [.print, .addToReadingList]
            if (UI_USER_INTERFACE_IDIOM() == .phone) {
                self.present(activityVC, animated: true, completion: nil)
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

    func sharingURL() -> NSURL? {
        return DynamicTableViewController.buildDynamicSharingURL(self.navigationController!, channel: self.channel) as NSURL
    }
    
    func openWebView(url: NSURL) {
        if #available(iOS 8.0, *) {
            if let vc = RUWKWebViewController(url: url as URL) {
                vc.showPageTitles = false
                vc.hideWebViewBoundaries = true
                vc.showUrlWhileLoading = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = RUUIWebViewController(url: url as URL) {
                vc.showPageTitles = false
                vc.hideWebViewBoundaries = true
                vc.showUrlWhileLoading = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    @IBAction func writeEmail(_ sender: UIButton) {
        if let url = NSURL(string: "mailto:wrnurutgersradio@gmail.com") {
            UIApplication.shared.openURL(url as URL)
        }
    }

    @IBAction func playRadio(_ sender: UIButton) {
        toggleRadio()
    }

    @IBAction func openTwitter(_ sender: UIButton) {
        if let url = NSURL(string: "https://twitter.com/WRNU") {
            openWebView(url: url)
        }
    }

    @IBAction func openInstagram(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.instagram.com/_wrnu/") {
            openWebView(url: url)
        }
    }

    @IBAction func openFacebook(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.facebook.com/CampusBeatRadio") {
            openWebView(url: url)
        }
    }

    @IBAction func openSoundcloud(_ sender: UIButton) {
        if let url = NSURL(string: "https://soundcloud.com/rutgers-wrnu") {
            openWebView(url: url)
        }
    }
}
