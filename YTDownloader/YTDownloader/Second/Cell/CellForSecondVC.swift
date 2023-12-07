//
//  CellForSecondVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit
import AVKit
import Photos

final class CellForSecondVC: UICollectionViewCell {

//    private var videoModel: VideoForUI?

//    var playerViewController = AVPlayerViewController()
    private var playerLayer: AVPlayerLayer?

    private lazy var baseView: UIView = {
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        return base
    }()

    private lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
//        let frame = UIView(frame: CGRect(x: 0, y: 95, width: screenWidth, height: 211))
//            let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
//            let player = AVPlayer(url: videoURL!)
//            let video = AVPlayerViewController()
//            video.player = player
//            video.view.frame = frame.bounds
//            frame.addSubview(video.view)
//            video.player?.play()
//            return frame
        return videoView
    }()



    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.addTarget(self, action: #selector(didTapPlay(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods
    func configureWith(model: VideoForUI) {
//        self.videoModel = model.video//??как присвоить видео из realm
//        self.dateLabel = model.date //??нужен еще форматтер
    }

    func configure(with asset: PHAsset) {
            let options = PHVideoRequestOptions()
            options.deliveryMode = .automatic
            PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { [weak self] playerItem, _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let player = AVPlayer(playerItem: playerItem)
                    self.playerLayer = AVPlayerLayer(player: player)
                    self.playerLayer?.frame = self.contentView.bounds
                    self.contentView.layer.addSublayer(self.playerLayer!)
                    player.play()
                }
            }
        }

//    func playVideoFromGallery() {
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
//            if let lastAsset = fetchResult.firstObject {
//                PHImageManager.default().requestPlayerItem(forVideo: lastAsset, options: nil) { (playerItem, info) in
//                    DispatchQueue.main.async {
//                        self.playerViewController.player = AVPlayer(playerItem: playerItem)
//                        self.present(self.playerViewController, animated: true) {
//                            self.playerViewController.player?.play()
//                        }
//                    }
//                }
//            }
//        }


    // MARK: - Private methods
    private func setupView() {
        [videoView, playButton, deleteButton, dateLabel].forEach { baseView.addSubview($0) }
        contentView.addSubview(baseView)
        contentView.backgroundColor = .gray
    }

    private func layout() {
        NSLayoutConstraint.activate([
            baseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: contentView.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            videoView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: baseView.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

            playButton.centerXAnchor.constraint(equalTo: videoView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: videoView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            playButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

            deleteButton.trailingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: -Constants.insetForCell),
            deleteButton.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: -Constants.insetForCell),
            deleteButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

            dateLabel.leadingAnchor.constraint(equalTo: videoView.leadingAnchor, constant: Constants.insetForCell),
            dateLabel.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: -Constants.insetForCell),
            dateLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width/( (Constants.insetForCell)/3) ),
            dateLabel.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
        ])
    }

    // MARK: - Actions
    @objc func didTapPlay(_ sender: UIButton) {
        guard let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") else { return }
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                UIApplication.shared.windows.first?.rootViewController?.present(playerViewController, animated: true) {
                    player.play()
                }
    }

    @objc func didTapDelete(_ sender: UIButton) {

    }

}
