//
//  Foundation.swift
//  StocksApp
//
//  Created by Bek Mashrapov on 2024-04-22.
//

import Foundation
struct StockData: Codable, Identifiable {
    let id = UUID()
    struct MetaData: Codable {
        var information: String
        var symbol: String
        var lastRefreshed: String
        var interval: String
        var outputSize: String
        var timeZone: String
        enum CodingKeys: String, CodingKey {
            case information = "1. Information"
            case symbol = "2. Symbol"
            case lastRefreshed = "3. Last Refreshed"
            case interval = "4. Interval"
            case outputSize = "5. Output Size"
            case timeZone = "6. Time Zone"
        }
    }
    struct StockDataEntry: Codable, Hashable {
        var open: String
        var high: String
        var low: String
        var close: String
        var volume: String
        enum CodingKeys: String, CodingKey {
            case open = "1. open"
            case high = "2. high"
            case low = "3. low"
            case close = "4. close"
            case volume = "5. volume"
        }
    }
    let metaData: MetaData
    let timeSeries5min: [String: StockDataEntry]
    private enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case timeSeries5min = "Time Series (5min)"
    }
    var latestClose: String {
        timeSeries5min.values.map { $0.close }.last ?? "N/A"
    }
    var closeValues: [Double] {
        let values = timeSeries5min.values.compactMap { Double($0.close) }
        guard let max = values.max(), let min = values.min(), max > min else {
            return values
        }
        return values.map { ($0 - min) / (max - min) }
    }
    var change: String {
        let closeValuesArray = timeSeries5min.values.map { Double($0.close) ?? 0.0 }
        guard closeValuesArray.count >= 2 else { return "N/A" }
        let change = closeValuesArray[closeValuesArray.count - 1] - closeValuesArray[closeValuesArray.count - 2]
        return String(format: "%.2f", change)
    }
}


