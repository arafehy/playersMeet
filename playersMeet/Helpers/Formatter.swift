//
//  Converter.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/27/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation

struct Formatter {
    private static let formatter = MeasurementFormatter()
    private static let dateFormatter = DateFormatter()
    
    static func getReadableString(measurement: Measurement<UnitLength>) -> String {
        formatter.unitOptions = .naturalScale
        return formatter.string(from: measurement)
    }
    
    static func getReadableDate(timeInterval: TimeInterval) -> String {
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        dateFormatter.dateFormat = "h:mma, MM/dd/yyyy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
    }
}
