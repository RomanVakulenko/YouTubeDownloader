//
//  JsonModelsURL.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 14.12.2023.
//

import Foundation

enum JsonModelsURL {

    static var inFM = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("models.json")
    
}
