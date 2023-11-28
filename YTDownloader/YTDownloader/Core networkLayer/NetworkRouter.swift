//
//  NetworkRouter.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation

protocol NetworkRouterProtocol {
    func requestDataWith(_ url: URL) async throws -> Data
}


final class NetworkRouter {

}


// MARK: - Extensions
extension NetworkRouter: NetworkRouterProtocol {

    func requestDataWith(_ url: URL) async throws -> Data {
        do {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 20// сервер не ответит - ошибка таймаута.
            configuration.timeoutIntervalForResource = 300// загрузка инфы (файла) не завершится - ошибка таймаута
            let session = URLSession(configuration: configuration)

            let (data, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode //ставил 500, но ??не выдает??
                if statusCode < 200 && statusCode > 299 {
                    throw RouterErrors.serverErrorWith(statusCode) // URLError.badServerResponse - //The URL Loading System received bad data from the server.
                }
            }
            return data
        } catch let error as NSError {
            switch error.code {
            case NSURLErrorBadURL: // как ЭТИ - свифтовые отловить??
                throw RouterErrors.badURL
            case NSURLErrorNotConnectedToInternet:
                throw RouterErrors.noInternetConnection
            case NSURLErrorTimedOut:
                print("Ошибка: Превышено время ожидания")
            default:
                print("Принт дефолт кейса роутера: \(error.description)")
            }
            print(error.code) // после разговора убрать (не попал в кейсы - принтит)
            print("Это принтит, когда в часть url'a (в path) добавляю тире --/v2/prices/latest")// после разговора убрать (не попала в кейсы - принтит)
            throw error
        }

    }
}
