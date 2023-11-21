//
//  GameLogics.swift
//  TumTumCha
//
//  Created by Eduardo Curupana on 17/05/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation

class GameLogics {
    
    let range: Float = 0.0625
    
    let numberOfLoops = 1
    var totalAccuracy = 0
    
    let minToPass = 50
    
    func createRange(beat: Beat) -> (Float, Float) {
        var lowRange = beat.position - range / 2
        var highRange = beat.position + range / 2
        
        if lowRange < 0 {
            lowRange = 1 + lowRange
        }
        if highRange >= 1 {
            highRange = highRange - 1
        }
        return (lowRange, highRange)
    }
    
    func checkTouchPosition(touch: Touch, beats: [Beat]) -> TouchOutput {
        print("Touch position: \(touch.position)")
        
        if beats.count > 0 {
            let beat = getClosestBeat(beats: beats, position: touch.position)
            let isTouchOnRange = checkTouchOnRange(of: beat, with: touch)
            let isTouchRight = checkTouchRight(beat: beat, touch: touch)
            
            if isTouchRight == true && isTouchOnRange == true {
                let distance = getDistance(from: touch.position, to: beat.position)
                let accuracy = calculateAccuracy(distance: distance)
                totalAccuracy = totalAccuracy + accuracy
                
                return .right(accuracy: accuracy)
            } else if isTouchRight == true && isTouchOnRange == false {
                return .outRange
            } else if isTouchRight == false && isTouchOnRange == true {
                return .wrongTouch
            } else if isTouchRight == false && isTouchOnRange == false {
                return .doubleFail
            } else {
                fatalError("Error!")
            }
        } else {
            fatalError("There is no beat on the wheel!")
        }
    }
    
    func checkTouchOnRange(of beat: Beat, with touch: Touch) -> Bool {
        let (lowRange, highRange) = createRange(beat: beat)
        if lowRange > highRange {
            if touch.position >= 0 && touch.position < highRange || touch.position < 1 && touch.position > lowRange {
                return true
            } else {
                return false
            }
        } else {
            if touch.position > lowRange && touch.position < highRange {
                return true
            } else {
                return false
            }
        }
    }
    
    func checkTouchRight(beat: Beat, touch: Touch) -> Bool {
        if touch.type == beat.kind {
            return true
        } else {
            return false
        }
    }
    
    func getDistance(from a: Float, to b: Float) -> Float {
        var distance = abs(a - b)
        
        if distance > range {
            distance = 1 - distance
        }
        
        return distance
    }
    
    func getClosestBeat(beats: [Beat], position: Float) -> Beat {
        var beat: Beat!
        for b in beats {
            if beat == nil {
                beat = b
            } else {
                let distToA = getDistance(from: position, to: b.position)
                let distToB = getDistance(from: position, to: beat.position)
                
                if distToA < distToB {
                    beat = b
                }
            }
        }
        return beat
    }
    
    func calculateAverage(totalAccuracy: Int, numberOfBeats: Int) -> Int {
        return totalAccuracy / numberOfBeats
    }
    
    func calculateWheelsAverage(wheels: [Wheel]) -> Int {
        var average = 0
        for w in wheels {
            average = average + w.accuracy
        }
        average = average / wheels.count
        return average
    }
    
    func calculateAccuracy(distance: Float) -> Int {
        return 100 - Int(distance * 100 / range)
    }
    
    func timeToPosition(_ time: TimeInterval, duration: TimeInterval) -> Float {
        return Float(time / duration)
    }
    
    func didPass(accuracy: Int) -> Bool {
        if accuracy >= minToPass {
            return true
        } else {
            return false
        }
    }
    
    func highscoreMessage(newScore: Int, oldScore: Int) -> String {
        if newScore > oldScore {
            return "NEW HIGHSCORE"
        } else {
            return "Highscore: \(oldScore)%"
        }
    }
    
    func passMessage(newScore: Int) -> (String, String) {
        if didPass(accuracy: newScore) {
            return ("Level Completed", "Accuracy: \(newScore)%")
        } else {
            return ("Level Failed", "Accuracy: \(newScore)%")
        }
    }
    
    func saveLevelAccuracy(accuracy: Int, worldId: Int, levelId: Int) {
        let dataManager = SaveDataManager()
        if getHighscore(levelId: levelId, worldId: worldId) == -1 {
            dataManager.saveData(idLevel: String(levelId), idWorld: String(worldId), accuracy: accuracy)
        } else {
            dataManager.modifyData(idLevel: String(levelId), idWorld: String(worldId), newAccuracy: accuracy)
        }
    }
    
    func getHighscore(levelId: Int, worldId: Int) -> Int {
        let dataManager = SaveDataManager()
        let lastAccuracy = dataManager.findOneLevel(idLevel: String(levelId), idWorld: String(worldId)) as! [Accuracy]
        
        if lastAccuracy.count == 0 {
            return -1
        } else {
            return Int(lastAccuracy[0].accuracy)
        }
    }
    
    func positionOnWhellOnSixteen(_ position: Float) -> Int {
        if position == 0 {
            return 0
        } else {
            return Int(16 * position)
        }
    }
    
    func positionOnWhellOnOne(_ position: Float) -> Float {
        if position == 0 {
            return 0
        } else {
            return 1 / 16 * position
        }
    }
}

enum TouchOutput {
    case right(accuracy: Int)
    case outRange
    case wrongTouch
    case doubleFail
}
