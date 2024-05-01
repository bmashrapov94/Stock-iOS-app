//
//  LineChart.swift
//  StocksApp
//
//  Created by Bek Mashrapov on 2024-04-22.
//

import Foundation

import SwiftUI

struct LineChart: Shape {
    var values: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !values.isEmpty else { return path }
        let start = CGPoint(x: rect.minX, y: rect.maxY - CGFloat(values.first!) * rect.maxY)
        path.move(to: start)

        for index in values.indices {
            let x = rect.width * CGFloat(index) / CGFloat(values.count - 1)
            let y = rect.maxY - CGFloat(values[index]) * rect.maxY
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}
