//
//  ViewController.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 7/31/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ProfileList: UIViewController{
    @IBOutlet weak var filterMenu: UIView!
    
    var ref:DatabaseReference!
    var profiles = [Profile]()
    var numSections = 1
    var originalProfileArray = [Profile]()
    var filterMenuOpen = false
    
    @IBOutlet weak var ageSortSegmentControl: UISegmentedControl!
    @IBOutlet weak var genderSortSegmentControl: UISegmentedControl!
    @IBOutlet weak var genderFilterSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        tableView.delegate = self
        tableView.estimatedRowHeight = 532
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.gray
        self.setupFilterMenuView()
        pullDatabase()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: -Preliminary functions
    func pullDatabase(){
        
        self.ref.child("Profiles").observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let key = snapshot.key
            //self.profiles.insert(Profile(profile: value, key: key), at: 0)
            self.originalProfileArray.append(Profile(profile: value, key: key))
            self.profiles = self.originalProfileArray
            self.tableView.reloadData()
        })
        
        self.ref.child("Profiles").observe(.childRemoved, with: { (snapshot) in
            let key = snapshot.key
            let index = self.originalProfileArray.index(where: { (profile) -> Bool in
                profile.profileID == key
            })
            self.originalProfileArray.remove(at: index!)
            self.profiles = self.originalProfileArray
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Button Actions
    @objc func viewProfileAction(_ sender:UITapGestureRecognizer){
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.profile = self.profiles[(sender.view?.tag)!]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cancelFilterMenu(_ sender: Any) {
        adjustView()
    }
    
    @IBAction func saveFilterMenuOptions(_ sender: Any) {
        adjustView()
        
        if self.ageSortSegmentControl.selectedSegmentIndex != 0 && self.genderSortSegmentControl.selectedSegmentIndex != 0 {
            self.profiles.sort {
                if $0.gender != $1.gender  {
                    switch self.genderSortSegmentControl.selectedSegmentIndex {
                    case 1:
                        return $0.gender > $1.gender
                    default:
                        return $0.gender < $1.gender
                    }
                }
                    
                else{
                    switch self.ageSortSegmentControl.selectedSegmentIndex {
                    case 1:
                        return $0.dob > $1.dob
                        break;
                    default:
                        return $0.dob < $1.dob
                    }
                }
            }
        }
        else if self.ageSortSegmentControl.selectedSegmentIndex == 0 && self.genderSortSegmentControl.selectedSegmentIndex == 0 && self.genderFilterSegmentControl.selectedSegmentIndex == 0{
            self.profiles = self.originalProfileArray
            self.tableView.reloadData()
            return
        }
        else {
            self.sortGender(selection: self.genderSortSegmentControl.selectedSegmentIndex)
            self.sortAge(selection: self.ageSortSegmentControl.selectedSegmentIndex)
        }
        self.filterGender(selection: self.genderFilterSegmentControl.selectedSegmentIndex)
        self.tableView.reloadData()
    }
    
    @IBAction func filterSortButtonPressed(_ sender: Any) {
        adjustView()
    }
}


//MARK - Filter Menu and Data processing functions
extension ProfileList {
    
    func setupFilterMenuView(){
        self.filterMenu.alpha = 0
        let distance = 0 - self.filterMenu.frame.height
        self.filterMenu.frame.origin = CGPoint(x: 0, y: distance)
    }
    
    func adjustView(){
        if self.filterMenuOpen {
            UIView.animate(withDuration: 0.3) {
                self.filterMenu.alpha = 0
                let distance = 0 - self.filterMenu.frame.height
                self.filterMenu.frame.origin = CGPoint(x: 0, y: distance)
            }
        }
        else{
            UIView.animate(withDuration: 0.3) {
                self.filterMenu.alpha = 1
                var distance:CGFloat = (self.navigationController?.navigationBar.frame.height)!
                if UIScreen.main.nativeBounds.height == 2436 {
                    let window = UIApplication.shared.keyWindow
                    let topPadding = window?.safeAreaInsets.top
                    distance = distance + topPadding!
                }
                else{
                    distance = distance + 20
                }
                self.filterMenu.frame.origin = CGPoint(x: 0, y: distance)
            }
        }
        self.filterMenuOpen = !self.filterMenuOpen
    }
    
    func sortAge(selection:Int){
        switch selection {
        case 2:
            self.profiles.sort(by: {$0.dob < $1.dob})
            break;
        case 1:
            self.profiles.sort(by: {$0.dob > $1.dob})
            break;
        default:
            print("default")
        }
    }
    
    func sortGender(selection:Int){
        switch selection {
        case 2:
            self.profiles.sort(by: {$0.dob < $1.dob})
            break;
        case 1:
            self.profiles.sort(by: {$0.dob > $1.dob})
            break;
        default:
            print("default")
        }
    }
    func filterGender(selection: Int){
        switch selection {
        case 2:
            self.profiles = self.originalProfileArray.filter{ $0.gender == "female"}
            break;
        case 1:
            self.profiles = self.originalProfileArray.filter{ $0.gender == "male"}
        default:
            print("default")
        }
    }
    
}

//MARK: - TableView Delegate Methods
extension ProfileList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if profiles[indexPath.row].gender == "female" {
            tableView.register(UINib(nibName: "ProfileListCellFemale", bundle: nil), forCellReuseIdentifier: "ProfileListCellFemale")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListCellFemale", for: indexPath) as! ProfileListCellFemale
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewProfileAction(_:)))
            cell.viewProfileButton.addGestureRecognizer(tapGesture)
            cell.viewProfileButton.tag = indexPath.row
            cell.setupCell(profile: profiles[indexPath.row])
            return cell
        }
        tableView.register(UINib(nibName: "ProfileListCellMale", bundle: nil), forCellReuseIdentifier: "ProfileListCellMale")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListCellMale", for: indexPath) as! ProfileListCellMale
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewProfileAction(_:)))
        cell.viewProfileButton.addGestureRecognizer(tapGesture)
        cell.viewProfileButton.tag = indexPath.row
        cell.setupCell(profile: profiles[indexPath.row])
        return cell
    }
}

