//
//  VideoPlayerViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/25/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class VideoPlayerViewController: UIViewController, VLCMediaPlayerDelegate {
    
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var fastReverseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var mediaPlayer: VLCMediaPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.delegate = self
        mediaPlayer?.drawable = self.movieView
        
        // You can test the player with urls below or just replace with a url of your own
        let url1 = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
        let url2 = "http://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4"
        
        mediaPlayer?.media = VLCMedia(url: URL(string: url1)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mediaPlayer?.state == VLCMediaPlayerState.paused {
            mediaPlayer?.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mediaPlayer?.pause()
    }
    
    @IBAction func rewind(_ sender: Any) {
        
        mediaPlayer?.rewind()
    }
    
    @IBAction func forward(_ sender: Any) {
        
        mediaPlayer?.fastForward()
    }
    
    @IBAction func userClickDone(_ sender: Any) {
        
        mediaPlayer?.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playandPause(_ sender: Any) {
        if (mediaPlayer?.isPlaying)! {
            mediaPlayer?.pause()
            playButton.setImage(UIImage(named: "ic_play_white"), for: .normal)
            playButton.imageView?.tintColor = UIColor.white
        } else {
            mediaPlayer?.play()
            playButton.setImage(UIImage(named: "ic_pause_white"), for: .normal)
            playButton.imageView?.tintColor = UIColor.white
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        
        timeLabel.text = mediaPlayer?.time.stringValue
    }
    
}
