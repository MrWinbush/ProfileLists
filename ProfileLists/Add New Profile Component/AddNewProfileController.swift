//
//  AddNewProfile.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 7/31/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import UIKit
import Firebase

class AddNewProfileController: UIViewController {

    @IBOutlet weak var changeProfileImageButton: UIButton!
    @IBOutlet weak var hobbiesTableView: UITableView!
    @IBOutlet weak var genderSegmentControl: UISegmentedControl!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addProfileImage: UIImageView!
    @IBOutlet weak var cancelPost: UIBarButtonItem!
    
    var hobbies = [String]()
    var picker = UIImagePickerController()
    var storage: StorageReference!
    var ref: DatabaseReference!
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)

        self.storage = Storage.storage().reference(forURL:"gs://passport-profile-list.appspot.com")
        self.ref = Database.database().reference()
        self.hobbiesTableView.delegate = self
        self.hobbiesTableView.dataSource = self
        self.picker.delegate = self
        self.createDatePicker()

        // Do any additional setup after loading the view.
    }
    
    //Used for resigning TextFields
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPostAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addProfileImage(_ sender: Any) {
        self.selectImage()
    }
    
    func createDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.maximumDate = Date()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let completeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishSelection))
        toolbar.setItems([completeButton], animated: true)
        self.dateOfBirthTextField.inputAccessoryView = toolbar
        self.dateOfBirthTextField.inputView = datePicker
    }
    
    @objc func finishSelection(){
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy") // set template after setting locale
        print(dateFormatter.string(from: self.datePicker.date)) // December 31
        self.dateOfBirthTextField.text = "\(dateFormatter.string(from: self.datePicker.date))"
        self.view.endEditing(true)
    }
    
    @IBAction func makePost(_ sender: Any){
        if self.dateOfBirthTextField.text != "" && self.nameTextField.text != "" && self.addProfileImage.image != #imageLiteral(resourceName: "man-add-mini"){
            print(self.genderSegmentControl.selectedSegmentIndex)
            if self.genderSegmentControl.selectedSegmentIndex == 0 {
                self.uploadProfile(name: self.nameTextField.text!, dob: "\(self.datePicker.date)", gender: "male", profileImage: self.addProfileImage.image!)
            }
            else{
                self.uploadProfile(name: self.nameTextField.text!, dob: "\(self.datePicker.date)", gender: "female", profileImage: self.addProfileImage.image!)
            }
            
        }
        else{
            print("This is incorrect")
        }
        
    }
    
    func uploadProfile(name: String, dob: String, gender: String, profileImage: UIImage){
        let profileID = self.ref.child("Profiles").childByAutoId().key
        let imageRef = self.storage.child("\(profileID).jpg")
        let data = UIImageJPEGRepresentation(profileImage, 0.6)
        let uploadTask = imageRef.putData(data!, metadata: nil){
            (metadata, error) in
            if error != nil{
                print("Error occuring in upload task \n")
                print(error!.localizedDescription)
            }
            imageRef.downloadURL(completion: { (url, er) in
                if er != nil{
                    print("Error happing on URL download \n")
                    print(er!.localizedDescription)
                }
                if let url = url {
                    let profile: [String: Any] = ["name" : name,
                                                   "gender" : gender,
                                                   "profileImageURL" : url.absoluteString,
                                                   "dateOfBirth":dob]
                    self.ref.child("Profiles").child(profileID).setValue(profile)
                    for hobby in self.hobbies {
                        let key = self.ref.child("Profiles").child(profileID).child("hobbies").childByAutoId().key
                        self.ref.child("Profiles").child(profileID).child("hobbies").child(key).setValue(hobby)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        uploadTask.resume()
    }
    
    @objc func searchImages(_ sender: Any){
        self.selectImage()
    }
}

//MARK: - Add Hobby Delegates
extension AddNewProfileController: EditHobbyDelegate {
    func addHobby(hobby: String) {
        self.hobbies.append(hobby)
        self.hobbiesTableView.reloadData()
    }
    
    func editHobby(hobby: String, key: String) {
        let index = Int(key)
        self.hobbies[index! - 1] = hobby
        self.hobbiesTableView.reloadData()
    }
    
    func removeHobby(hobby: Hobby) {
        let key = Int(hobby.key)! - 1
        self.hobbies.remove(at: key)
        self.hobbiesTableView.reloadData()
    }

}

//MARK: - UIImagePickerViewDelegates
extension AddNewProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func selectImage(){
        let alertController = UIAlertController(title: "Add New Profile Image", message: "Everyone wants to see who you are!", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        })
        
        let library = UIAlertAction(title: "Library", style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(camera)
        alertController.addAction(library)
        alertController.addAction(cancel)
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.addProfileImage.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - TableView Delegate Methods
extension AddNewProfileController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            tableView.register(UINib(nibName: "AddHobbyHeaderCell", bundle: nil), forCellReuseIdentifier: "AddHobbyHeaderCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddHobbyHeaderCell", for: indexPath) as! AddHobbyHeaderCell
            return cell
        }
        tableView.register(UINib(nibName: "HobbyItemCell", bundle: nil), forCellReuseIdentifier: "HobbyItemCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyItemCell", for: indexPath) as! HobbyItemCell
        cell.hobbyLabel.text = self.hobbies[indexPath.row - 1]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hobbies.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Function")
        if indexPath.row == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "EditHobbyController") as! EditHobbyController
            vc.hobbyDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "EditHobbyController") as! EditHobbyController
            let selectedIndex = "\(indexPath.row)"
            vc.hobbyObject = Hobby(k: selectedIndex, h: hobbies[indexPath.row - 1])
            vc.isNewHobby = false
            vc.hobbyDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
