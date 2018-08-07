//
//  Profiles.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 7/31/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import Foundation

struct Profile {
    var profileID: String
    var name: String
    var gender: String
    var age: Int
    var profileImageURL: String
    var hobbies = [Hobby]()
    var dob: Date
    
    init(profile:NSDictionary, key: String){
        self.profileID = key
        self.name = profile["name"] as! String
        self.gender = profile["gender"] as! String
        
        //Converting String to date
        let dobString = profile["dateOfBirth"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        self.dob = dateFormatter.date(from: dobString)!
        
        //Converting DOB into Numeric Age
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: self.dob, to: now)
        self.age = ageComponents.year!
        
        self.profileImageURL = profile["profileImageURL"] as! String
        
        if let hobbyList = profile["hobbies"] as? NSDictionary{
            for hobbies  in hobbyList {
                self.hobbies.append(Hobby(k: hobbies.key as! String, h: hobbies.value as! String))
            }
        }
    }
}
