//
//  World.swift
//  TumTumCha
//
//  Created by Eduardo Curupana on 21/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation

struct World: Decodable {
    var id: Int
    var levels: [Level]?
    var levelPaths: [String]
}

struct JSONFiles {
    static let worldOne = "World1.json"
}
