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
    
    static func getReadableString(measurement: Measurement<UnitLength>) -> String {
        formatter.unitOptions = .naturalScale
        return formatter.string(from: measurement)
    }
}
