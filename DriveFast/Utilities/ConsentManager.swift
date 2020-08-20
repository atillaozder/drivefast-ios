//
//  ConsentManager.swift
//  DriveFast
//
//  Created by Atilla Özder on 20.08.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import UserMessagingPlatform

// MARK: - ConsentManager

final class ConsentManager {
    
    static let shared = ConsentManager()
    private var requestForConsent: Bool
    
    private init() {
        self.requestForConsent = false
    }
        
    func requestConsent(completion: @escaping (UMPConsentForm?) -> ()) {
        guard !requestForConsent else {
            completion(nil)
            return
        }
        
        self.requestForConsent = true
        
        let params = UMPRequestParameters()
        params.tagForUnderAgeOfConsent = false
                
        #if DEBUG
        let debugSettings = UMPDebugSettings()
        debugSettings.geography = .EEA
        debugSettings.testDeviceIdentifiers = ["BA3432BE-D2C3-46CD-BE13-436CDFC17F83"]
        params.debugSettings = debugSettings
        #endif
        
        let consentInformation = UMPConsentInformation.sharedInstance
        consentInformation.requestConsentInfoUpdate(with: params) { [unowned self] (error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
            
            let formStatus = consentInformation.formStatus
            switch formStatus {
            case .available:
                print("Log Message: Consent is available.")
                self.loadConsentForm(completion: completion)
            case .unavailable, .unknown:
                print("Log Message: Consent is unavailable or unknown.")
                completion(nil)
            @unknown default:
                print("Log Message: Consent is unknown.")
                completion(nil)
            }
        }
    }
    
    private func loadConsentForm(completion: @escaping (UMPConsentForm?) -> ()) {
        UMPConsentForm.load { (form, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            
            let consentStatus = UMPConsentInformation.sharedInstance.consentStatus
            switch consentStatus {
            case .required:
                completion(form)
            case .notRequired, .unknown:
                print("Log Message: Consent Form is notRequired or unknown.")
                completion(nil)
            case .obtained:
                print("Log Message: Consent Form is obtained.")
                completion(nil)
            @unknown default:
                print("Log Message: Consent Form is unknown.")
                completion(nil)
            }
        }
    }
}
