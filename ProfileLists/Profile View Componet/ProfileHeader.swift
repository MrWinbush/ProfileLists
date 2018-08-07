//
//  ProfileListCell.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 7/31/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileHeader: UITableViewCell {
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        secondView.layer.cornerRadius = 8
        profileImage.layer.cornerRadius = 8
        secondView.layer.borderColor = UIColor.black.cgColor
        secondView.layer.borderWidth = 0.5
    }
    
    func setupCell(profile: Profile){
        self.nameLabel.text = profile.name
        self.ageLabel.text = "Age: \(profile.age)"
        self.profileImage.sd_setImage(with: URL(string: profile.profileImageURL))
        switch (profile.gender){
        case "male":
            self.genderLabel.text = "Male"
            self.contentView.setGradientBackground(color: UIColor(named: "Male")!)
            break;
        case "female":
            self.genderLabel.text = "Female"
            self.contentView.setGradientBackground(color: UIColor(named: "Female")!)
            break;
        default:
            print("Incompatible data type")
        }
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
