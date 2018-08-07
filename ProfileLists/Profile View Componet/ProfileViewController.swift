//
//  ProfileViewController.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 8/1/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var profile:Profile!
    var selectedIndex:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = self.profile.name
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor(named: "White Color")
        print(profile.profileID)
        self.ref = Database.database().reference().child("Profiles").child("\(profile.profileID)")
        self.initDatabase()
    }

    //MARK: -Initializing Database
    func initDatabase(){
        self.profile.hobbies.removeAll()
        self.ref.child("hobbies").observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as! String
            let key = snapshot.key
            self.profile.hobbies.append(Hobby(k: key, h: value))
            self.tableView.reloadData()
        })
        
        self.ref.child("hobbies").observe(.childRemoved, with: { (snapshot) in
            let key = snapshot.key
            let index = self.profile.hobbies.index(where: { (hobby) -> Bool in
                hobby.key == key
            })
            self.profile.hobbies.remove(at: index!)
            self.tableView.reloadData()
        })
        
        self.ref.child("hobbies").observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let index = self.profile.hobbies.index(where: { (hobby) -> Bool in
                hobby.key == key
            })
            self.profile.hobbies[index!].hobby = snapshot.value as! String
            self.tableView.reloadData()
        })

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2 + profile.hobbies.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 0:
            break;
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "EditHobbyController") as! EditHobbyController
            vc.hobbyDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            break;
        default:
            let vc = storyboard?.instantiateViewController(withIdentifier: "EditHobbyController") as! EditHobbyController
            selectedIndex = indexPath.row
            vc.hobbyObject = profile.hobbies[indexPath.row - 2]
            vc.isNewHobby = false
            vc.hobbyDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            tableView.register(UINib(nibName: "ProfileHeader", bundle: nil), forCellReuseIdentifier: "ProfileHeader")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeader", for: indexPath) as! ProfileHeader
            cell.setupCell(profile: profile)
            return cell
        }
        else if indexPath.row == 1 {
            tableView.register(UINib(nibName: "AddHobbyHeaderCell", bundle: nil), forCellReuseIdentifier: "AddHobbyHeaderCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddHobbyHeaderCell", for: indexPath) as! AddHobbyHeaderCell
            return cell
        }
        tableView.register(UINib(nibName: "HobbyItemCell", bundle: nil), forCellReuseIdentifier: "HobbyItemCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyItemCell", for: indexPath) as! HobbyItemCell
        cell.hobbyLabel.text = profile.hobbies[indexPath.row - 2].hobby
        return cell
    }

    //MARK: - Deleting a profile
    @IBAction func deleteProfile(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Profile", message: "Are you sure you want to delete this profile?", preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            self.ref.removeValue(completionBlock: { (err, snapsot) in
                if err != nil {
                    print(err?.localizedDescription ?? "error occured")
                }
                else{
                    self.navigationController?.popViewController(animated: true)
                }
            })
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        alertController.addAction(delete)
        alertController.addAction(cancel)
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
}

//MARK: -EditHobby delegate method implementation
extension ProfileViewController: EditHobbyDelegate {
    func addHobby(hobby: String) {
        let key = ref.child("hobbies").childByAutoId().key
        ref.child("hobbies").child(key).setValue(hobby)
    }
    
    func editHobby(hobby: String, key: String) {
        ref.child("hobbies").child(key).setValue(hobby)
    }
    
    func removeHobby(hobby: Hobby) {
        ref.child("hobbies").child(hobby.key).removeValue()
    }
}
