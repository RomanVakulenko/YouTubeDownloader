//
//  Alerts.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 30.11.2023.
//

import Foundation
import UIKit

enum AlertCases {
    case invalidURL, fileExists, XCDDidNotGetVideo, videoSavedToPhotoLibrary
}

enum ShowAlert {

    static func type(_ : AlertCases, at vc: UIViewController, message: String) {
        let alertController = UIAlertController(
            title: "You Down",
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Ok", style: .destructive))

        vc.present(alertController, animated: true)
    }

}
