//
//  HeaderForSecondVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit

final class HeaderForSecondVC: UICollectionReusableView {

    // MARK: - Private properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .red
        label.text = "You Down"
        label.textColor = .black
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
