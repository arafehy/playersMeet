//
//  Formatter.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/27/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation

struct Formatter {
    private static let measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        return formatter
    }()
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static func getReadableMeasurement(_ measurement: Measurement<UnitLength>) -> String {
        return measurementFormatter.string(from: measurement)
    }
    
    static func getReadableDate(timeInterval: TimeInterval) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
    }
}
