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


final class CellForShowVC: UICollectionViewCell {

    // MARK: - Public properties
    var didTapDeleteClosure: (() -> Void)?
    var didTapPlayClosure: (() -> Void)?

    // MARK: - Private properties
    private var urlOfVideoInFM: URL?
    
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

    // MARK: - Public methods
    ///c помощью UIMediaItem, которая  имеет date и URL  к mp4 в FileManager
    func configure(with uiMediaItem: MediaItemProtocol?) {

        if let uiModel = uiMediaItem {
            urlOfVideoInFM = uiModel.mp4URLWithPathInFMForPlayer
            dateLabel.text = DateManager.createStringFromDate(uiModel.dateOfDownload, andFormatTo: "dd.MM.yy")

            if let imageData = try? Data(contentsOf: uiModel.jpgURLWithPathInFMForPlayer!),
               let image = UIImage(data: imageData) {
                thumbnailImageView.image = image
            }
            /// так можно получить заставку, если в metadata не будет thumbnail
            else if uiModel.jpgURLWithPathInFMForPlayer == nil {
                guard let url = urlOfVideoInFM else { return }

                let asset = AVAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                let time = CMTimeMake(value: 1, timescale: 2) // можно указать время кадра
                if let imageRef = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                    let thumbnail = UIImage(cgImage: imageRef)
                    thumbnailImageView.image = thumbnail
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
            videoView.heightAnchor.constraint(equalTo: contentView.heightAnchor),

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
    @objc func didTapPlay(_ sender: UIButton) {
        didTapPlayClosure?()
    }

    @objc func didTapDelete(_ sender: UIButton) {
        didTapDeleteClosure?()
    }

}
