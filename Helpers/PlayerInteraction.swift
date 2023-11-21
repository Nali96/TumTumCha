//
//  GestureClass.swift
//  GestureApp
//
//  Created by Marco Di Fiandra on 20/05/2019.
//  Copyright © 2019 Marco Di Fiandra. All rights reserved.
//



//To enable the gesture first call the varaiable to chose 'kindOfInteraction' than enable the gesture using the 'enable gesture function'

import Foundation
import UIKit
import SpriteKit

enum ActionsType: Int{
    case multiTap
    case swipe
    case singleTap
}

enum ScreenSide {
    case right
    case left
    case bottom
}

struct Multipliers {
    static let singleTapMultiplier: CGFloat = 0.78
}


protocol PlayerInteractionDelegate: AnyObject { //Use this to place the beat type on the wheel
    func didPutBeatOfType(_ type: BeatType)
}

protocol Interaction { //Protocol for enabling gesture for the user when he need
    var delegate: PlayerInteractionDelegate? { get set }
    var isEnabled: Bool { get set } // Use this attribute to enable or disable the gestures
    func setupGestures() //Function to enable the gestures
}

class PlayerInteraction { // The class that will enable the gesture for the users
    
    private var view: UIView
    private var kindOfInteraction: Interaction?
    
    weak var delegate: PlayerInteractionDelegate?
    
    var isEnabled: Bool = true {
        didSet {
            kindOfInteraction?.isEnabled = isEnabled
        }
    }
    
    init(view: UIView, delegate: PlayerInteractionDelegate?, settings: SettingsData ) {
        
        self.view = view
        self.view.isUserInteractionEnabled = true
        
        switch settings.gesture {
        case .multiTap:
            kindOfInteraction = TapInteraction(view: view, isAxsisInverted: settings.invertAxis )
        case .swipe:
            kindOfInteraction = SwipeInteraction(view: view)
        case .singleTap:
            kindOfInteraction = SingleTapInteraction(view: view, isAxsisInverted: settings.invertAxis )
        }
        
        kindOfInteraction?.setupGestures()
        kindOfInteraction?.delegate = delegate
    }
}

class SwipeInteraction: Interaction { // Class to handle the kind of swipe: up,down,right and left
    
    var isEnabled: Bool = true {
        didSet {
            swipeGestureMain?.isEnabled = isEnabled
            swipeGestureSecondary?.isEnabled = isEnabled
        }
    }
    
    private var view: UIView
    private var swipeGestureMain: UISwipeGestureRecognizer!
    private var swipeGestureSecondary: UISwipeGestureRecognizer!
    
    weak var delegate: PlayerInteractionDelegate?
    
    init(view: UIView) {
        self.view = view
    }
    
    func setupGestures() {
        
        swipeGestureMain = UISwipeGestureRecognizer(target: self, action: #selector(place(_:)))
        swipeGestureSecondary = UISwipeGestureRecognizer(target: self, action: #selector(place(_:)))
        
        swipeGestureMain.delaysTouchesEnded = false
        swipeGestureSecondary.delaysTouchesEnded = false
        
        swipeGestureMain.direction = [.up, .down]
        swipeGestureSecondary.direction = [.left, .right]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(placeTap))
        
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeGestureMain)
        view.addGestureRecognizer(swipeGestureSecondary)
    }
    
    @objc func place(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case [.left, .right]:
            delegate?.didPutBeatOfType(.secondary)
        case [.up, .down]:
            delegate?.didPutBeatOfType(.main)
        default:
            break
        }
    }
    
    @objc func placeTap() {
        delegate?.didPutBeatOfType(.off)
    }
}

class TapInteraction: Interaction { //Class to manage the single and multi tap interaction
    
    var isEnabled: Bool = true {
        didSet {
            singleTap?.isEnabled = isEnabled
            multiTouchGesture?.isEnabled = isEnabled
        }
    }
    
    private var view: UIView
    private var singleTap: UITapGestureRecognizer!
    private var multiTouchGesture: UITapGestureRecognizer!
    private var isAxisInverted: Bool!
    
    weak var delegate: PlayerInteractionDelegate?
    
    init(view: UIView, isAxsisInverted: Bool) {
        self.view = view
        self.isAxisInverted = isAxsisInverted
    }
    
    func setupGestures() {
        
        view.isMultipleTouchEnabled = true
        singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapRecognizer(_:)))
        multiTouchGesture = UITapGestureRecognizer(target: self, action: #selector(multitouchRecognizer))
        multiTouchGesture.numberOfTouchesRequired = 2
        
        
        multiTouchGesture.delaysTouchesEnded = false
        singleTap.delaysTouchesEnded = false
        
        
        view.addGestureRecognizer(singleTap)
        view.addGestureRecognizer(multiTouchGesture)
    }
    
    @objc func singleTapRecognizer(_ sender: UITapGestureRecognizer) {
        let tappedSite: ScreenSide  = tapSideLocation(sender)
        switch tappedSite {
        case .left:
            delegate?.didPutBeatOfType(.off)
        case .right:
            delegate?.didPutBeatOfType(.secondary)
        default:
            print("Problem")
        }
//        if tapOnTheLeft(sender) {
//            delegate?.didPutBeatOfType(.off)
//        } else {
//            delegate?.didPutBeatOfType(.secondary)
//        }
    }
    
    @objc func multitouchRecognizer() {
        delegate?.didPutBeatOfType(.main)
    }
    
    func tapSideLocation(_ sender: UITapGestureRecognizer) -> ScreenSide { //function to recognize where i tapped
        var side: ScreenSide!
        if sender.location(in: view).x <= (view.frame.width/2) {
            if isAxisInverted{
                side = .right
            }
            else{
            side = .left
            }
        }
        else
        {
            if isAxisInverted {
                side = .left
            }
            else
            {
                side = .right
            }
        }
        return side
    }
}


class SingleTapInteraction: Interaction {
    
    private var view: UIView
    var delegate: PlayerInteractionDelegate?
    private var tapGesture: UITapGestureRecognizer!
    private var isAxisInverted: Bool!
    
    var isEnabled: Bool = true {
        didSet {
            tapGesture.isEnabled = self.isEnabled
        }
    }
    
    init(view: UIView, isAxsisInverted: Bool) {
        self.view = view
        self.isAxisInverted = isAxsisInverted
    }
    
    func setupGestures() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(_:)))
        view.addGestureRecognizer(tapGesture)
        tapGesture.delaysTouchesEnded = false
    }
    
    @objc
    func tapRecognized(_ sender: UITapGestureRecognizer)
    {
        
        let tappedSite: ScreenSide = tapSideLocation(sender)
        switch tappedSite {
        case .bottom:
            delegate?.didPutBeatOfType(.main)
        case .left:
            delegate?.didPutBeatOfType(.off)
        case .right:
            delegate?.didPutBeatOfType(.secondary)
        }
//        if(tapOnTheLeft(sender) ) {
//            delegate?.didPutBeatOfType(.off)
//        }
//        else if(tapInTheBottom(sender)) {
//            delegate?.didPutBeatOfType(.main)
//        }
//        else
//        {
//            delegate?.didPutBeatOfType(.secondary)
//        }
        
       
    }
    
    
    func tapSideLocation(_ sender: UITapGestureRecognizer) -> ScreenSide { //function to recognize where i tapped

        let verticalCoordinatesX = view.frame.width/2
        let verticalCoordinatesY = view.frame.height * Multipliers.singleTapMultiplier
        let horizontalcoordinates = view.frame.height * Multipliers.singleTapMultiplier
        
        var side: ScreenSide!
        if (sender.location(in: view).x <= verticalCoordinatesX && (sender.location(in: view).y < verticalCoordinatesY)) {
            if(isAxisInverted){
                side = .right
            }
            else {
                side = .left
            }
        }
        else if sender.location(in: view).y >= horizontalcoordinates {
            side = .bottom
        }
        else {
            if(isAxisInverted){
                side = .left
            }
            else {
                side = .right
            }
        }
        return side
    }
    
    
    
}


extension ActionsType: Codable {
    
    enum Key: CodingKey {
        case rawValue
    }
   
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        
        switch rawValue {
        case 0:
            self = .swipe
        case 1:
            self = .multiTap
        case 2:
            self = .singleTap
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        
        switch self {
        case .swipe:
            try container.encode(0, forKey: .rawValue)
        case .multiTap:
             try container.encode(1, forKey: .rawValue)
        case .singleTap:
            try container.encode(2, forKey: .rawValue)
        }
    }
}

