//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinData)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "B4136416-9F1C-4226-B3F1-AB5CB92AB224"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
        
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let crypto = parseJSON(safeData) {
                        delegate?.didUpdateCoin(self, coin: crypto)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ crypto: Data) -> CoinData? {
        let decoder = JSONDecoder()
        do {
            let decoderData = try decoder.decode(CoinData.self, from: crypto)
            let time = decoderData.time
            let assetIdBase = decoderData.asset_id_base
            let assetIdQuote = decoderData.asset_id_quote
            let rate = decoderData.rate
            
            let crypto = CoinData(time: time, asset_id_base: assetIdBase, asset_id_quote: assetIdQuote, rate: rate)
            return crypto
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

