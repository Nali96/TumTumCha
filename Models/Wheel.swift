//
//  Wheel.swift
//  Wheel Logics
//
//  Created by Eduardo Curupana on 14/05/2019.
//  Copyright © 2019 Eduardo Curupana. All rights reserved.
//

import Foundation

struct Wheel: Decodable {
    var id: Int? = 0
    var beats: [Beat]
    var audioName: String
    var instrument: String
    var accuracy: Int = 0
    
    init(beats: [Beat], audioName: String, instrument: String) {
        self.beats = beats
        self.audioName = audioName
        self.instrument = instrument
    }
}
