//
//  ImageError.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 10/30/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import Foundation

enum ImageError: Error {
    case invalidData
    case invalidMetadata
    case invalidDownloadURL
    case nilImage
}
