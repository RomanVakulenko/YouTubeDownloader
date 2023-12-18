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

    // MARK: - Public properties
    var didTapDeleteClosure: (() -> Void)?

    // MARK: - Private properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var urlToVideoInFM: URL?
    
    private lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        return videoView
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = false
        return imageView
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

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    // MARK: - Public methods
    ///c помощью UIMediaItem, которая  имеет date и URL  к mp4 в FileManager
    func configure(with uiMediaItem: MediaItemProtocol?) {

        if let uiModel = uiMediaItem {
            urlToVideoInFM = uiModel.mp4URLInFileManager //это путь до mp4 видеофайла, который лежит в FileManager
            dateLabel.text = DateManager.createStringFromDate(uiModel.dateOfDownload, andFormatTo: "dd.MM.yy")
            if let url = urlToVideoInFM {
                let asset = AVAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                let time = CMTimeMake(value: 1, timescale: 2) // Здесь можно указать нужное время для получения кадра
                if let imageRef = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                    let thumbnail = UIImage(cgImage: imageRef)
                    //                    thumbnailImageView.image = thumbnail

                    if let imageData = try? Data(contentsOf: uiModel.thumbnailURL!),
                       let image = UIImage(data: imageData) {
                        thumbnailImageView.image = image
                        //                    #error("по идее, в модели есть URL картинки")
                    }
                }
            }

        }
    }


    // MARK: - Private methods
    private func setupView() {
        videoView.addSubview(thumbnailImageView)
        [videoView, playButton, deleteButton, dateLabel].forEach { contentView.addSubview($0) }
        contentView.backgroundColor = .lightGray
    }
    private func layout() {
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoView.heightAnchor.constraint(equalToConstant: playerLayer?.bounds.height ?? contentView.bounds.height * 1),

            thumbnailImageView.leadingAnchor.constraint(equalTo: videoView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: videoView.trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: videoView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: videoView.bottomAnchor),

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
    //    @objc func didTapPlay(_ sender: UIButton) { //Если надо, чтобы только внутри ячейки, то использовать AVPlayer
    //        thumbnailImageView.isHidden = true
    //        guard let url = urlToVideoInFM else { return }
    //
    //        let playerItem = AVPlayerItem(url: url)  //заставки также нет и видео не проигрывается
    //        player = AVPlayer(playerItem: playerItem)
    //        playerLayer = AVPlayerLayer(player: player)
    //        playerLayer?.frame = videoView.bounds
    //        videoView.layer.addSublayer(playerLayer!)
    //        player?.play()
    //    }

    @objc func didTapPlay(_ sender: UIButton) { //а так на весь экран плеер открывается
        guard let url = urlToVideoInFM else { return }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIApplication.shared.keyWindow?.rootViewController?.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }

    @objc func didTapDelete(_ sender: UIButton) {
        didTapDeleteClosure?()
    }

}
