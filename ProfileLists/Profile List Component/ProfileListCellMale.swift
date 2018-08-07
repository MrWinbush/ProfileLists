//
//  ProfileListCell.swift
//  ProfileLists
//
//  Created by Morgan Winbush on 7/31/18.
//  Copyright © 2018 Passport. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileListCellMale: UITableViewCell {
    
    @IBOutlet weak var viewProfileButton: UIButton!
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
        viewProfileButton.layer.borderWidth = 0.5
        viewProfileButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func setupCell(profile: Profile){
        self.nameLabel.text = profile.name
        self.ageLabel.text = "Age: \(profile.age)"
        self.profileImage.sd_setImage(with: URL(string: profile.profileImageURL))
        self.genderLabel.text = "Male"
        self.contentView.setGradientBackground(color: UIColor(named: "Male")!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
