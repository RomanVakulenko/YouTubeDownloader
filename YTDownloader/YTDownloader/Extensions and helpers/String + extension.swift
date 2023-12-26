//
//  String + extension.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 30.11.2023.
//

import Foundation

extension String {
    ///extracts YouTube video id
  func extractYoutubeId() -> String? {
    let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/)|(?<=shorts/))([\\w-]++)"
    guard let matchRange = self.range(of: pattern, options: .regularExpression) else { return .none }
    return String(self[matchRange])
  }
    
}
