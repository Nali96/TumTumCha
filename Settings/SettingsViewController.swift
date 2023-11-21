//
//  SettingsViewController.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 03/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

//Cancellare reference nella main storyboard
// e il perform segue

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var invertAxis: UISwitch!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let gestures: [ActionsType] = [.multiTap, .swipe, .singleTap]
    let gestureNames: [String] = ["Tap", "Swipe", "Single Tap"]
    
    var settings: SettingsData?
    let settingsController = UserDefaultSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = ""
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backItem?.title = "ABCD"
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: .white, NSAttributedString.Key.]
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let settingsData = settingsController.retrieve()
        invertAxis.isOn = settingsData.invertAxis
        pickerView.selectRow(settingsData.gesture.rawValue, inComponent: 0, animated: false)
    }
    

    
    @IBAction func btnSave(_ sender: Any) {
        settingsController.save(settingData: SettingsData(invertAxis: invertAxis.isOn, gesture: gestures[pickerView.selectedRow(inComponent: 0)]))
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gestures.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gestureNames[row]
    }
    
    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
