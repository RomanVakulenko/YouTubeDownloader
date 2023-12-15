//
//  MapperError.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation

enum MapperError: Error, CustomStringConvertible {
    case failAtMapping(reason: String)

    var description: String {
        switch self {
        case .failAtMapping(let reason):
            return reason
        }
    }
}
