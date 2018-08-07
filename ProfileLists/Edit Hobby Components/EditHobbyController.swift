//
//  EditHobbyController.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 8/5/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import UIKit
import Firebase

protocol EditHobbyDelegate {
    
    func addHobby(hobby:String)
    func removeHobby(hobby:Hobby)
    func editHobby(hobby:String, key:String)
}

class EditHobbyController: UIViewController {
    
    var hobbyDelegate:EditHobbyDelegate!
    
    var isNewHobby = true
    var fromCreateProfile = true
    var hobbyObject:Hobby!
    
    @IBOutlet weak var removeHobby: UIButton!
    @IBOutlet weak var hobbyTextArea: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isNewHobby {
            self.removeHobby.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.hobbyObject != nil{
            self.hobbyTextArea.text = self.hobbyObject.hobby
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        if self.hobbyTextArea.text != "" {
            if !isNewHobby {
                hobbyDelegate.editHobby(hobby: self.hobbyTextArea.text, key: self.hobbyObject.key)
            }
            else{
                hobbyDelegate.addHobby(hobby: self.hobbyTextArea.text)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func removeHobbyAction(_ sender: Any) {
        hobbyDelegate.removeHobby(hobby: Hobby(k: self.hobbyObject.key,h: self.hobbyTextArea.text))
        self.navigationController?.popViewController(animated: true)
    }

}
