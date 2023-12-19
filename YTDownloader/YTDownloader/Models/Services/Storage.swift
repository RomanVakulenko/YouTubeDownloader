//
//  Storage.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 19.12.2023.
//

import Foundation

final class Storage {

    // MARK: - Public properties
    public static let shared = Storage()

    public var dataModelsStoredInFM: [VideoItemData] = [] {
        didSet{
            encodeAndSaveModelsArrAsJsonFileToFM(dataModels: dataModelsStoredInFM)
        }
    }

    // MARK: - Init
    private init() {}

    // MARK: - Private properties
    private let mapper = DataMapper()

    // MARK: - Private methods
    private func encodeAndSaveModelsArrAsJsonFileToFM(dataModels: [VideoItemData]) {
        do {
            ///кодируем data из [VideoItemData] для сохранения videoItemData в FM
            let data = try mapper.encode(from: dataModels)
            ///сохраняем в FM по уникальному url
            try data.write(to: JsonModelsURL.inFM)
            print("\(dataModels), this array encoded to \(data) & saved to \(JsonModelsURL.inFM)")
        } catch {
            print("Error saving data to FileManager: \(error.localizedDescription)")
        }
    }

}
