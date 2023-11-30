//
//  MapperError.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation

enum MapperError: Error, CustomStringConvertible {
    case failAtParsing(reason: String)

    var description: String {
        switch self {
        case .failAtParsing(let reason):
            return reason
        }
    }
}
