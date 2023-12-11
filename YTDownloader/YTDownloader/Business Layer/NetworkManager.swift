//
//  NetworkManager.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation
import UIKit

protocol NetworkManagerProtocol: AnyObject {
    func getDecodedModel<T: Decodable>(using url: URL, into model: T.Type) async throws -> T
}

final class NetworkManager { // только скачивает и декодирует JSON в struct

    // MARK: - Private properties
//    private let networkRouter: NetworkRouterProtocol
    private let mapper: MapperProtocol

    // MARK: - Init
    init( mapper: MapperProtocol) {
//        self.networkRouter = networkRouter
        self.mapper = mapper
    }

}

// MARK: - Extensions
//extension NetworkManager: NetworkManagerProtocol {
//    
//    func getDecodedModel<T: Decodable>(using url: URL, into model: T.Type) async throws -> T {
//        do {
//            let data = try await networkRouter.requestDataWith(url)
//            let decodedModel = try mapper.decode(from: data, toStruct: model)
//            return decodedModel
//        } catch let error as RouterErrors {
//            throw NetworkManagerErrors.networkRouterErrors(error: error)
//        } catch let error as MapperError {
//            throw NetworkManagerErrors.mapperErrors(error: error)
//        }
//    }
//
//}
