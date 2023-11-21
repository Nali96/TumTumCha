//
//  Tutorial.swift
//  TumTumCha
//
//  Created by Eduardo Curupana on 04/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation

struct Tutorial: Decodable {
    var id: Int!
    var type: BeatType!
    var steps: [Step]!
}

struct Step: Decodable {
    var message: String
    var pausePosition: Int
    var beatKind: BeatType
    var wheelCount: Int
}
