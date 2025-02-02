/*
 * Copyright 2018 Russell Wolf
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import Shared

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet var typePicker: UIPickerView!
    @IBOutlet var valueInput: UITextField!
    @IBOutlet var outputText: UILabel!
    @IBOutlet var loggingSwitch: UISwitch!
    @IBOutlet var loggingText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        typePicker.delegate = self
        typePicker.dataSource = self
        valueInput.delegate = self
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return settingsRepository.mySettings[row].key
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settingsRepository.mySettings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        refresh()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func onSetButtonPress() {
        guard let row = typePicker?.selectedRow(inComponent: 0) else {
            return
        }
        guard let value = valueInput?.text else {
            return
        }
        let settingConfig = settingsRepository.mySettings[row]
        if (settingConfig.set(value: value)) {
            outputText.text = ""
        } else {
            outputText.text = "INVALID VALUE!"
        }
    }

    @IBAction func onGetButtonPress() {
        guard let row = typePicker?.selectedRow(inComponent: 0) else {
            return
        }
        let settingConfig = settingsRepository.mySettings[row]
        outputText.text = settingConfig.get()
    }

    @IBAction func onRemoveButtonPress() {
        let row = typePicker.selectedRow(inComponent: 0)
        let settingConfig = settingsRepository.mySettings[row]
        settingConfig.remove()
        outputText.text = "Setting Removed!"
    }

    @IBAction func onClearButtonPress() {
        settingsRepository.clear()
        outputText.text = "Settings Cleared!"
    }
    
    @IBAction func onLoggingSwitchChanged() {
        guard let row = typePicker?.selectedRow(inComponent: 0) else {
            return
        }
        settingsRepository.mySettings[row].isLoggingEnabled = loggingSwitch?.isOn ?? false
    }
    
    @IBAction func onImplementationToggleChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            settingsRepository = userDefaultsSettingsRepository
            loggingSwitch.alpha = 1
            outputText.text = "Now reading from UserDefaults"
        } else {
            settingsRepository = keychainSettingsRepository
            loggingSwitch.alpha = 0
            outputText.text = "Now reading from Keychain"
        }
        refresh()
    }
    
    private func refresh() {
        if (settingsRepository == userDefaultsSettingsRepository) {
            loggingSwitch.alpha = 1
            loggingText.alpha = 1
        } else {
            loggingSwitch.alpha = 0
            loggingText.alpha = 0
        }
        loggingSwitch.setOn(settingsRepository.mySettings[typePicker.selectedRow(inComponent: 0)].isLoggingEnabled, animated: true)
    }
}

let userDefaultsSettingsRepository: SettingsRepository = SettingsRepository(settings: NSUserDefaultsSettings(delegate: UserDefaults.standard))
let keychainSettingsRepository: SettingsRepository = SettingsRepository(settings: KeychainSettings(service: "Settings Demo"))

var settingsRepository = userDefaultsSettingsRepository

