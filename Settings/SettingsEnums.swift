//
//  SettingsEnums.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 05/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
    var selectable: Bool { get }
    var goToAnotherPage: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible  {
    
    case general
    case gesture
    case aboutUs
    case tutorial

    var description: String {
        switch self {
            case .general: return "GENERAL"
            case .gesture: return "GESTURES"
            case .aboutUs: return "ABOUT US"
            case .tutorial: return "DATA"
        }
    }
}

enum GeneralSettings: Int, CaseIterable, SectionType {
    
    case lefthanded
    case showCouter
    
    var containsSwitch: Bool { return true }
    
    var selectable: Bool { return false }
    
    var goToAnotherPage: Bool { return false }
    
    var description: String{
        switch self {
        case .lefthanded: return "LeftHanded"
        case .showCouter: return "Show Counter"
        }
    }
}

enum GestureSettings: Int, CaseIterable, SectionType {
    
    case singleTap
    case swipe
    case multiTap
    
    var containsSwitch: Bool { return false }
    
    var selectable: Bool { return true }
    
    var goToAnotherPage: Bool { return false }

    var description: String {
        switch self {
        case .singleTap: return "SplitScreen"
        case .swipe: return "Swipe"
        case .multiTap: return "MultiTap"
        }
    }
    
    var actionsType: ActionsType {
        switch self {
        case .singleTap:
            return .singleTap
        case .swipe:
            return .swipe
        case .multiTap:
            return .multiTap
        }
    }
}

enum AboutUsSettings: Int, CaseIterable, SectionType {
    
//    case info
    case contacts
    
    var containsSwitch: Bool { return false }
    
    var selectable: Bool { return false }
    
    var goToAnotherPage: Bool { return true }
    
    var description: String {
        switch self {
        case .contacts: return "Credits"
//        case .info: return "Info"
        }
    }
}

enum TutorialSettings: Int, CaseIterable, SectionType {
    
    case reDoTutorial
    
    var containsSwitch: Bool { return false }
    
    var selectable: Bool { return false }
    
    var goToAnotherPage: Bool { return false}
    
    var description: String {
        switch self {
        case .reDoTutorial: return "Reset"
        }
    }
}
