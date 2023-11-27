//
//  CellForSecondVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit

final class CellForSecondVC: UICollectionViewCell {

    private lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
        return videoView
    }()

//    let frame = UIView(frame: CGRect(x: 0, y: 95, width: screenWidth, height: 211))
//        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
//        let player = AVPlayer(url: videoURL!)
//        let video = AVPlayerViewController()
//        video.player = player
//        video.view.frame = frame.bounds
//        frame.addSubview(video.view)
//        video.player?.play()
//        return frame

}
