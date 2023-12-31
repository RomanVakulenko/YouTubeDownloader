//
//  FirstVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit


final class DownloadViewController: UIViewController {

    // MARK: - Private properties
    var startDate: Date?
    var stopDate: Date?
    private var viewModel: DownloadViewModel

    private let baseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .red
        label.text = "YouTubeDownloader"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 19)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var referenceTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Put your YouTube link"
        textField.layer.borderWidth = 0.6
        textField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        textField.layer.cornerRadius = 8
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.font = .systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        textField.tintColor = .systemBlue
        textField.alpha = 0.8
        textField.backgroundColor = .systemGray6
        textField.autocapitalizationType = .none
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        return textField
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(downloadAndSaveToGallery(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var historyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray6
        button.setTitle("Downloaded video", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.6
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.addTarget(self, action: #selector(didTapDownloadedVideo(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var boxProgressView: UIView = {
        let boxView = UIView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: self.view.frame.width * 0.65, height: 72)
        )
        boxView.backgroundColor = .none
        boxView.layer.borderColor = .none
        boxView.center = self.view.center
        boxView.isHidden = true
        return boxView
    }()

    private lazy var progressView: UIProgressView = {
        let pView = UIProgressView(frame: CGRect(x: boxProgressView.frame.width * 0.1,
                                                 y: boxProgressView.frame.height * 0.8,
                                                 width: boxProgressView.frame.width * 0.8,
                                                 height: 2))
        pView.progressTintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return pView
    }()

    private lazy var titleProgress: UILabel = {
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 0,
                                             width: progressView.frame.width,
                                             height: progressView.frame.minY - 10))
        titleLbl.text = title ?? ""
        titleLbl.font = UIFont.init(name: "DINCondensed-Bold", size: 30)
        titleLbl.textAlignment = .center
        titleLbl.center = progressView.center
        titleLbl.frame = CGRect(x: titleLbl.frame.minX, y: 5,
                                width: titleLbl.frame.width, height: titleLbl.frame.height)
        return titleLbl
    }()


    // MARK: - Init
    init(viewModel: DownloadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bindViewModel() //here bounds are ready for spinner
    }

    // MARK: - Private methods
    private func setupView() {
        [titleProgress, progressView].forEach { boxProgressView.addSubview($0) }
        [titleLabel, referenceTextField, downloadButton, historyButton, Show.spinner, boxProgressView].forEach { baseView.addSubview($0)}
        view.addSubview(baseView)
        view.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            baseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.headerHeight),

            referenceTextField.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: Constants.insetForCell * 2),
            referenceTextField.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -(Constants.buttonSize+Constants.insetForCell * 2)),
            referenceTextField.centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            referenceTextField.heightAnchor.constraint(equalToConstant: Constants.buttonSize * 1.32),

            downloadButton.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -Constants.insetForCell),
            downloadButton.centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            downloadButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),


            historyButton.topAnchor.constraint(equalTo: referenceTextField.bottomAnchor, constant: Constants.headerHeight*2),
            historyButton.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: Constants.headerHeight * 3),
            historyButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize * 1.32)
        ])
    }

    private func bindViewModel() {
        DispatchQueue.main.async {
            self.viewModel.closureChangingState = { [weak self] state in
                guard let self else {return}

                DispatchQueue.main.async {
                    switch state {
                    case .none:
                        ()
                    case .processing:
                        Show.spinner.startAnimating()

                    case .fileExists:
                        Show.spinner.stopAnimating()
                        ShowAlert.type(.fileExists, at: self, message: "File already exists, search field is cleared for your convenience")
                        self.referenceTextField.text = nil

                    case .loading:
                        Show.spinner.stopAnimating()
                        self.startDate = Date()
                        //progress
                        self.progressView.progress = 0.0
                        self.boxProgressView.isHidden = false
                        self.viewModel.fManager.progressClosure = { observingProgress in
                            self.progressView.progress = observingProgress
                        }

                    case .loadedAndSaved:
                        self.boxProgressView.isHidden = true
                        self.stopDate = Date()
                        print("Время загрузки: \(self.stopDate!.timeIntervalSince(self.startDate!)) секунд")
                        ShowAlert.type(.videoSavedToPhotoLibrary, at: self, message: "Video saved")
                        self.referenceTextField.text = nil

                    case .badURL(alertText: let alertTextForUser):
                        Show.spinner.stopAnimating()
                        self.boxProgressView.isHidden = true
                        ShowAlert.type(.invalidURL, at: self, message: alertTextForUser)
                        self.referenceTextField.text = nil

                    case .thereIsNoAnyVideo:
                        ShowAlert.type(.thereIsNoAnyVideo, at: self, message: "There is no any video")
                        self.referenceTextField.text = nil
                    }
                }
            }
            
        }

    }

    @objc private func downloadAndSaveToGallery(_ sender: UIButton) {
        if referenceTextField.text != "" {
            guard let newText = referenceTextField.text,
                  let url = URL(string: newText),
                  ["m.youtube.com", "www.youtube.com", "youtube.com", "youtu.be"].contains(url.host),
                  let videoID = newText.extractYoutubeId() else {
                viewModel.state = .badURL(alertText: "Invalid YouTube URL")
                return
            }
            viewModel.downloadAndSaveVideo(at: videoID, and: url)
        }
    }

    @objc private func didTapDownloadedVideo(_ sender: UIButton) {
        viewModel.showSecondVC()
    }

}
