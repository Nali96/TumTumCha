//
//  TableViewController.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 05/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    private let settings: UserDefaultSettings = UserDefaultSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SettingsCell.self, forCellReuseIdentifier: "Cell")
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    func getSavedGestureSettings() -> GestureSettings {
        let saves: SettingsData = settings.retrieve()
        switch saves.gesture {
        case .swipe: return GestureSettings.swipe
        case .multiTap: return GestureSettings.multiTap
        case .singleTap: return GestureSettings.singleTap
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        switch section {
        case .general: return GeneralSettings.allCases.count
        case .gesture: return GestureSettings.allCases.count
        case .tutorial: return TutorialSettings.allCases.count
        case .aboutUs: return AboutUsSettings.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SettingsCell
        cell.delegate = self
        
        cell.textLabel?.textColor = .white
        cell.backgroundColor = #colorLiteral(red: 0.1860481799, green: 0.1759673357, blue: 0.1849023998, alpha: 1)
        cell.textLabel?.font = UIFont(name: "System", size: 24)
        
        guard let section = SettingsSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .general:
            cell.sectionType = GeneralSettings(rawValue: indexPath.row)
            if let cellType = cell.sectionType as? GeneralSettings {
                switch cellType {
                case .lefthanded:
                    cell.switchControl.isOn = settings.retrieve().invertAxis
                case .showCouter:
                    cell.switchControl.isOn = settings.retrieve().showCounter
                }
            }
            
        case .gesture:
            cell.sectionType = GestureSettings(rawValue: indexPath.row)
            if let cellType = cell.sectionType as? GestureSettings {
                cell.accessoryType = cellType == getSavedGestureSettings() ? .checkmark : .none
            }
            
        case .aboutUs:
            cell.sectionType = AboutUsSettings(rawValue: indexPath.row)
            
        case .tutorial:
            cell.sectionType = TutorialSettings(rawValue: indexPath.row)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            let gesture = settings.retrieve().gesture
            switch gesture {
            case .multiTap:
                return "Tap with two fingers to place main beats. Tap on the right or the left side of the screen to place secondary and off beats according to Lefthanded mode."
            case .singleTap:
                return "Tap on the bottom of the screen to place main beats. Tap on the right or the left side of the screen to place secondary and off beats according to Lefthanded mode."
            case .swipe:
                return "Swipe down to place main beats, swipe left or right to place secondary beat and tap to place secondary and off beats."
            }
        case 2:
            return ""
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        let title = UILabel()
        title.font = UIFont(name: "System", size: 35)
        title.textColor = .gray
        title.text = SettingsSection(rawValue: section)?.description
        view.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .general:
            print("general selected")
        case .gesture:
            if let cellType = cell.sectionType as? GestureSettings {
                var settingsToSave = settings.retrieve()
                settingsToSave.gesture = cellType.actionsType
                settings.save(settingData: settingsToSave)
                tableView.reloadSections(IndexSet([SettingsSection.gesture.rawValue]), with: .none)
            }
            
        case .aboutUs:
            if let cellType = cell.sectionType as? AboutUsSettings {
                switch cellType {
                case .contacts:
                    performSegue(withIdentifier: SegueNames.showContact, sender: self)
                }
            }
        case .tutorial:
            showAlert(title: "Reset data", message: "Are you sure you want to reset your progress and settings?")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            SaveDataManager().deleteAllData()
            self.settings.resetSettings()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - SettingsCellDelegate

extension TableViewController: SettingsCellDelegate {
    
    func didSwitchStatusChange(cell: SettingsCell, isOn: Bool) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        guard let sectionType = cell.sectionType, sectionType.containsSwitch else {
            return
        }
        
        guard let section = SettingsSection(rawValue: indexPath.section) else {
            return
        }
        
        if section == .general, let cellType = cell.sectionType as? GeneralSettings {
            switch cellType {
            case .lefthanded:
                var settingsToSave = settings.retrieve()
                settingsToSave.invertAxis = isOn
                settings.save(settingData: settingsToSave)
            case .showCouter:
                var settingsToSave = settings.retrieve()
                settingsToSave.showCounter = isOn
                settings.save(settingData: settingsToSave)
            }
        }
    }
}
