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
        label.text = "You Down"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 19)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        addSubview(titleLabel)
        titleLabel.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
