//
//  CellForSecondVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit

final class CellForSecondVC: UICollectionViewCell {

    private var videoModel: VideoForUI?

    private lazy var baseView: UIView = {
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        return base
    }()

    private lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false

    //    let frame = UIView(frame: CGRect(x: 0, y: 95, width: screenWidth, height: 211))
    //        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
    //        let player = AVPlayer(url: videoURL!)
    //        let video = AVPlayerViewController()
    //        video.player = player
    //        video.view.frame = frame.bounds
    //        frame.addSubview(video.view)
    //        video.player?.play()
    //        return frame
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

    }

    @objc func didTapDelete(_ sender: UIButton) {

    }

}
