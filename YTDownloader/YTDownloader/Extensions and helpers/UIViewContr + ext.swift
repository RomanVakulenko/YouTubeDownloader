//
//  UIViewContr + ext.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 01.12.2023.
//
import Foundation
import UIKit
// MARK: - UIViewController
enum Circular {
    static var progressView: UIView?
}
extension UIViewController {
    func showProgressView(onView : UIView, withTitle title: String?) {
        let progressV = UIView.init(frame: onView.bounds)
        progressV.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let boxView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.65, height: 80))
        boxView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        boxView.layer.cornerRadius = 10.0
        boxView.layer.borderWidth = 2.0
        boxView.layer.borderColor = .none
        boxView.center = progressV.center
        let pBar = UIProgressView(frame: CGRect(x: boxView.frame.width*0.1, y: boxView.frame.height * 0.8, width: boxView.frame.width*0.8, height: 2))
        pBar.tag = 10
        pBar.progressTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pBar.progress = 0.0
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: pBar.frame.width, height: pBar.frame.minY - 10))
        titleLbl.text = title ?? ""
        titleLbl.font = UIFont.init(name: "DINCondensed-Bold", size: 30)
        titleLbl.textAlignment = .center
        titleLbl.center = pBar.center
        titleLbl.frame = CGRect(x: titleLbl.frame.minX, y: 5,
                                width: titleLbl.frame.width, height: titleLbl.frame.height)
        DispatchQueue.main.async {
            boxView.addSubview(titleLbl)
            boxView.addSubview(pBar)
            progressV.addSubview(boxView)
            onView.addSubview(progressV)
        }
        Circular.progressView = progressV
    }

    func updateProgressView(to value: Double) {
        //        DispatchQueue.main.async {
        (Circular.progressView?.viewWithTag(10) as! UIProgressView).progress = Float(value)
        //        }
    }

    func removeProgressView() {
        //        DispatchQueue.main.async {
        Circular.progressView?.removeFromSuperview()
        Circular.progressView = nil
        //        }
    }
}
