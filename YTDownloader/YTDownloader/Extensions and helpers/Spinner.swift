//
//  Spinner.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 30.11.2023.
//

import Foundation
import UIKit

enum Show {
    static let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner.layer.cornerRadius = 8
        spinner.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height / 2) + 16)
        return spinner
    }()
}
