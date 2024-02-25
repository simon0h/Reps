//
//  SingleRepCell.swift
//  Reps
//
//  Created by Simon Oh on 1/27/24.
//

import UIKit

class SingleRepCell: UITableViewCell {

    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var workoutWeight: UILabel!
    @IBOutlet weak var weightImageView: UIImageView!
    @IBOutlet weak var workoutNameCell: UIView!
    @IBOutlet weak var workoutDetailCell: UIView!
    
    var markedDone = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
