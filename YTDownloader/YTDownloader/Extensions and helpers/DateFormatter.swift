//
//  DateFormatter.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 14.12.2023.
//

import Foundation

final class DateManager {
    static let dateFormatter = DateFormatter()

//    static func createDateFromString(_ string: String, incommingFormat format: String) -> Date? {
//        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale(identifier: "ru_RU")
//        return dateFormatter.date(from: string)
//    }

    static func createStringFromDate(_ date: Date, andFormatTo format: String) -> String {
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return dateFormatter.string(from: date)
    }
}
