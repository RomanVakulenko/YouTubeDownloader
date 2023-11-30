//
//  FirstVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit

final class FirstVC: UIViewController {

    // MARK: - Private properties
    private var viewModel: FirstViewModel

    private let baseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel() 
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .red
        label.text = "You Down"
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
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        return textField
    }()

    private var videoIDFromEnteredURL = String()

    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(download(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var historyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray6
        button.setTitle("History", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.6
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.addTarget(self, action: #selector(showHistory(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Init
    init(viewModel: FirstViewModel) {
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

    // MARK: - Private methods
    private func setupView() {
        [titleLabel, referenceTextField, downloadButton, historyButton].forEach { baseView.addSubview($0)}
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

            referenceTextField.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: Constants.insetForCell),
            referenceTextField.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -(Constants.buttonSize+Constants.insetForCell * 2)),
            referenceTextField.centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            referenceTextField.heightAnchor.constraint(equalToConstant: Constants.buttonSize * 1.32),

            downloadButton.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -Constants.insetForCell),
            downloadButton.centerYAnchor.constraint(equalTo: baseView.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            downloadButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),


            historyButton.topAnchor.constraint(equalTo: referenceTextField.bottomAnchor, constant: Constants.headerHeight*2),
            historyButton.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: Constants.headerHeight * 2),
            historyButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize * 1.32)
        ])
    }

    private func bindViewModel() {
        viewModel.closureChangingState = { [weak self] state in
            guard let strongSelf = self else {return}

            switch state {
            case .none:
                <#code#>
            case .processing:
                <#code#>
            case .loading:
                <#code#>
            case .loadedAndSaved:
                <#code#>
            case .badURL(alertText: let alertText):
                <#code#>
            case .deleted:
                <#code#>
            case .pasted:
                <#code#>
            }
        }
    }

    @objc private func download(_ sender: UIButton) {
        let videoID = videoIDFromEnteredURL
        viewModel.downloadVideo(at: videoID)
    }


    @objc private func showHistory(_ sender: UIButton) {
        viewModel.showSecondVC()
    }

}


// MARK: - Extensions UITextFieldDelegate
extension FirstVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        videoIDFromEnteredURL = textField.text?.extractYoutubeId() ?? ""
    }
}
