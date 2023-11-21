//
//  Beat.swift
//  Wheel Logics
//
//  Created by Eduardo Curupana on 14/05/2019.
//  Copyright © 2019 Eduardo Curupana. All rights reserved.
//

import Foundation

struct Beat: Decodable {
    var id: Int? = 0
    var kind: BeatType
    var position: Float
    
    init(kind: BeatType, position: Float) {
        self.kind = kind
        self.position = position
    }
}

enum BeatType: String, Decodable {
    case main = "main"
    case secondary = "secondary"
    case off = "off"
}
