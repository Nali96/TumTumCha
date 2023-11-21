//
//  DataJSONDecoder.swift
//  TumTumCha
//
//  Created by Eduardo Curupana on 21/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation

class LevelsProvider {
    
    func getWorldFromJSON(filename fileName: String) -> World? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(World.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func getLevelFromJSON(filename fileName: String) -> Level? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Level.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func getLevelById(id: Int, worldFileName: String) -> Level? {
        var level: Level!
        if let levelFilesName = getWorldFromJSON(filename: worldFileName) as World? {
            for fileName in levelFilesName.levelPaths {
                if let levelJson = getLevelFromJSON(filename: fileName) as Level? {
                    if levelJson.id == id {
                        level = levelJson
                    }
                }
            }
        }
        return level
    }
    
    func getAllLevelFromWorld(worldFileName fileName: String) -> [Level] {
        var levels: [Level] = []
        
        if let world = getWorldFromJSON(filename: fileName) as World? {
            for levelPath in world.levelPaths {
                if let level = getLevelFromJSON(filename: levelPath) as Level? {
                    levels.append(level)
                }
            }
        }
        
        return levels
    }
}
