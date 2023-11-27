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
    private var viewModel: FirstViewModel?

    private lazy var titleLabel: UILabel = {
        let label = UILabel() 
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .red
        label.text = "You Down"
        label.textColor = .black
        return label
    }()

    private lazy var referenceTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Put your YouTube link"
        return textField
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        return button
    }()

    private lazy var historyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.text = "History"
        return button
    }()

    // MARK: - Init
    init(viewModel: FirstViewModel) {
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func setupView() {
        [titleLabel, referenceTextField, downloadButton, historyButton].forEach { view.addSubview($0)}
        view.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    }

    private func layout() {
        NSLayoutConstraint.activate([

        ])
    }

    private func bindViewModel() {
        viewModel?.closureChangingState = { [weak self] state in
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

}
